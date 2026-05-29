# PFC02 Architecture Boundary And Module Map Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-66311469

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
PFC manifest because the global order selected PFC02 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC02`
- Name: Architecture Boundary And Module Map
- Train: PFC Platform / Framework / Compliance
- Type: Docs/audit
- Owner: Architecture

## Purpose

Map feature, domain, service, shared package, test, preview, app, extension,
runtime, persistence, and integration boundaries. Identify boundary risks,
large-file risks, and extraction queues without changing app code.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md`
- `docs/audits/me12-maintainability-handoff-report.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
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

- PFC02 architecture boundary audit report.
- Module/ownership map.
- Boundary risk table.
- Extraction and repair queue for PFC03/PFC05/FCP/AOS owner batches.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

No build/test command is required unless PFC02 changes production code, which it
must not do.

## Green / Yellow / Red

Green: docs-only boundary map is complete, no forbidden files touched, boundary
risks are owned, and PFC03 is named as next eligible batch.

Yellow: existing large files, known boundary advisories, or generated/prompt
artifact risks are documented with future owners.

Red: production source/config edits, route/raw-value change, dependency/workflow
change, or unresolved architecture contradiction requiring code changes in this
batch.

## Commit Message

`PFC02: Map architecture boundaries`

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
