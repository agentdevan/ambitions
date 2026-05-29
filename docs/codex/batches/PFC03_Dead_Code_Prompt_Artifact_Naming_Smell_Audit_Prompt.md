# PFC03 Dead Code / Prompt Artifact / Naming Smell Audit Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-70637776, AMB28-same_source_file_targeted_by_multiple_active_batches-94129696

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Queued Platform / Framework / Compliance batch; generated from the
PFC manifest because the global order selected PFC03 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC03`
- Name: Dead Code / Prompt Artifact / Naming Smell Audit
- Train: PFC Platform / Framework / Compliance
- Type: Audit/repair planning
- Owner: Maintainability

## Purpose

Identify likely dead files, prompt-built residue, stale names, duplicate model
risk, placeholder copy, and unexplained folders. PFC03 creates a cleanup queue
and ownership map only; it does not delete, rename, or rewrite source files.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Codex_Quality_System.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc02-architecture-boundary-module-map-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Allowed Files

- `docs/audits/**`
- `docs/codex/**`
- `.codex/reports/**`

## Forbidden Files

- `Native/**`
- `Sources/**`
- `AppUI/**`
- `.github/workflows/**`
- `project.yml`
- `Package.swift`
- lockfiles
- signing, entitlement, provisioning, workflow, dependency, generated build, and
  Xcode project files

## Required Deliverables

- PFC03 audit report.
- Prompt-artifact and naming-smell classification table.
- Cleanup queue with owners and proof required before deletion/rename.
- Explicit separation of legitimate placeholders/stubs from user-facing or
  release-handoff risk.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-prompt-built-smell-scan.sh Native || true`
- `scripts/cqs-prompt-built-smell-scan.sh Sources || true`
- `scripts/cqs-product-drift-scan.sh Native || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

No build/test command is required unless PFC03 changes production code, which it
must not do.

## Green / Yellow / Red

Green: docs-only audit is complete, no forbidden files touched, findings are
classified, and no source deletion/rename is attempted without owner proof.

Yellow: legitimate stubs/placeholders, stale copy, compatibility naming, or
prompt-smell scan hits remain but are classified with owner and repair path.

Red: production source/config edits, deletion or rename without owner proof,
unsupported release/legal/security claim, or unresolved evidence that a finding
is user-facing dangerous and cannot be bounded in docs.

## Commit Message

`PFC03: Audit prompt artifacts naming smells`

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
