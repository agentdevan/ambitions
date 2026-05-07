# RHC01-RHC06 Repo Hygiene Closeout Train
<!-- markdownlint-disable MD013 -->

Status: Queued governance / implementation train. Do not run before the active global full-stack order selects it.
Date: 2026-05-07
Train code: RHC

## Purpose

RHC makes the known repo hygiene debt executable without interrupting the live LDI/AOS/FCP/PFC sequence. It converts existing PFC01-PFC03 Yellow-owned cleanup findings into scoped, proof-bound batches that Codex can run automatically only after higher-priority full-stack gates are complete or accepted Yellow.

## Safe Insertion Rule

RHC is intentionally queued after the active full-stack tail:

1. LDI05-LDI22
2. AOS24-AOS30
3. FCP27-FCP30
4. PFC31-PFC40
5. RHC01-RHC06

Codex must not select RHC while the current active batch pointer names an unfinished LDI, AOS, FCP, or PFC batch. RHC may run earlier only if a Hard Red proves repo hygiene blocks the active batch and the repair is explicitly limited to the blocking owner files.

## Source Truth To Read First

- README.md
- AGENTS.md
- .codex/reports/current-run-state.md
- .codex/reports/current-batch-train-state.md
- docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md
- docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
- docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md
- docs/audits/pfc01-repo-build-system-inventory-report.md
- docs/audits/pfc02-architecture-boundary-module-map-report.md
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Hard Guardrails

- Do not alter active batch selection away from the live next eligible LDI/AOS/FCP/PFC batch.
- Do not delete files based on name smell alone.
- Do not rename route/raw-value, deep-link, App Intent, widget, notification, persistence, or compatibility seams without owner proof and focused tests.
- Do not weaken validators, drift scans, copy scans, release-claim scans, or architecture scans to pass.
- Do not make release, App Store, TestFlight, physical-device, legal/privacy, sync/cloud, public accessibility, or full-runtime claims.
- Do not add hosted workflow files.
- Do not expand oversized files while trying to clean them.

## Common Validation

Every RHC batch must run or record not-run reason:

- git status --short
- git diff --check
- scripts/run-doc-qa.sh || true
- scripts/batch-train-gate-check.sh || true
- scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true when architecture/source is touched
- scripts/cqs-prompt-built-smell-scan.sh Native || true when source is touched
- scripts/cqs-prompt-built-smell-scan.sh Sources || true when shared packages are touched
- scripts/cqs-product-drift-scan.sh Native || true when user-facing copy or compatibility names are touched
- focused xcodebuild tests when production Swift is touched
- scripts/build-local.sh when production Swift, package boundaries, project generation, external surfaces, or shared UI packages are touched

## Batch Order

### RHC01 — Repo Hygiene Triage And Owner Map

Type: Docs/audit.
Goal: Reconcile PFC01-PFC03 findings into a current owner map and determine which cleanup items still exist after the active train progress.
Allowed: docs/audits, docs/codex, non-mutating scripts only when needed.
Green: Current cleanup queue is owner-mapped with no source edits and no active batch pointer change.

### RHC02 — Large File Extraction And Module Boundary

Type: Implementation/tests if still needed.
Goal: Reduce architecture risk in the highest-priority oversized owners without behavior changes.
Owners: GoalsFeatureService, TodayFeatureService, ProfileScreen, PlanFeatureService, ProfileFeatureService, PlanScreen, GoalsFeatureModels, TodayPanels, and large domain/shared files only when proof says they still exceed thresholds.
Green: Extracted helpers/models/projectors have focused tests or the batch records a safe no-op if later trains already solved the issue.

### RHC03 — Placeholder Stub And Compatibility Seam Cleanup

Type: Implementation/tests.
Goal: Resolve Yellow-owned placeholder/stub/compatibility seams only where owner proof exists.
Targets: FutureIntegrationPlaceholders.swift, AppShellPlaceholderRouteView, shell.placeholder, preview/test stubs, and compatibility vocabulary.
Green: No unsafe route/raw-value/deep-link/persistence/external-surface break; focused tests prove behavior.

### RHC04 — Stale Copy Docs And Generated Artifact Hygiene

Type: Docs/copy/source hygiene.
Goal: Remove stale future-batch visible copy, deprecated active guidance, markdownlint backlog where safe, and generated/local artifact confusion.
Green: User-facing copy no longer references obsolete train mechanics; docs distinguish active policy from history; no source behavior changes unless owned.

### RHC05 — Validation Script Noise And Allowlist Hardening

Type: Scripts/docs.
Goal: Reduce advisory noise without weakening detection.
Green: Allowlists are narrow, named, and justified; scans still catch real product drift, prompt residue, release-claim drift, and architecture violations.

### RHC06 — Repo Hygiene Closeout And Handoff

Type: Audit/handoff.
Goal: Produce final hygiene scorecard and remaining Yellow register.
Green: Repo hygiene closeout report names remaining owners, proves no unowned cleanup debt is blocking, and preserves final proof gates.

## Non-Claims

RHC does not prove final release readiness, App Store readiness, TestFlight readiness, signed archive readiness, physical-device proof, legal/privacy approval, public accessibility conformance, or full architecture perfection. It exists to make known cleanup debt scheduled, safe, and evidence-bound.
