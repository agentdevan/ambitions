<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Validation Harness And Proof Hardening

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T16-VALIDATION-HARNESS

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T16-VALIDATION-HARNESS prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T16-VALIDATION-HARNESS.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Make validation durable, structured, and proof-honest.

## Active source truth to inspect
Truth files, scripts, build/audits, build/reports, docs/status/release-evidence-packet.md, validation docs, Makefile.

## Allowed scope
Validation scripts/harnesses, report schemas, log paths, proof docs, Makefile validation targets, reset validation proof.

## Forbidden scope
No hosted CI, signing/upload automation, release claim, secret handling, app behavior change, or false Green.

## Implementation requirements
Validators must exist or active expectations must be corrected. Capture environment, branch, SHA, commands, exit codes, logs. Timeout is Yellow unless a real source failure occurs.

## Visual proof expectations
None unless visual validation harness is touched; report proof boundaries.

## Accessibility expectations
No conformance claim without actual accessibility proof.

## Privacy / trust expectations
No secret/network/cost-bearing service; local-only proof artifacts.

## Continuity expectations
Generated validator side effects must be owned or restored.

## Validation expectations
Run prompt validators, batch ID validator, Codex OS validator, `xcodegen generate`, package resolution/build when environment allows, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Required validator missing, source/build failure due changes, false Green emitted, or hosted CI/signing introduced.

## Rollback expectations
Restore touched validation scripts/reports/Makefile entries from this train.

## Expected final report format
Command matrix with exit codes/log paths, Green/Yellow/Red, non-claims, next gate.

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
