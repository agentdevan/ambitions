# CQS01-CQS24 Codex Quality System Train

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-10983828, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-53091603, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-65413798, AMB28-same_source_file_targeted_by_multiple_active_batches-66311469, AMB28-same_source_file_targeted_by_multiple_active_batches-70637776, AMB28-same_source_file_targeted_by_multiple_active_batches-73720386, AMB28-same_source_file_targeted_by_multiple_active_batches-94129696, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS quality train inserted after PD17 and before PD18
Date: 2026-05-05

## Purpose

CQS upgrades the Ambitions Codex Operating System so remaining Product Depth,
FCP, PFC, AOS, LDI, and handoff batches run with mature repair cycles, senior
review gates, anti-agentic-code scans, and hard-Red-only stopping.

This train does not implement product features and does not authorize broad app
implementation.

## Continuation Rule

CQS may continue automatically across CQS batches when each batch closes Green
or Accepted Yellow, no production Swift is touched unless explicitly scoped,
and validation is Adequate or Strong. CQS stops only for Hard Red.

## Batch List

- CQS01: Codex OS Constitution / AGENTS.md Hardening. Upgrade AGENTS.md and/or
  canonical Codex behavior docs so Codex behaves like a senior FAANG iOS
  engineer. No broad changes, speculative abstractions, generic cards, or fake
  claims.
- CQS02: Senior iOS Architecture Reviewer Skill. Add/update
  `.codex/skills/staff-ios-architect.md`.
- CQS03: SwiftUI Composition Reviewer Skill. Add/update
  `.codex/skills/swiftui-composition-reviewer.md`.
- CQS04: Apple Design Award Visual Reviewer Skill. Add/update
  `.codex/skills/apple-design-award-visual-reviewer.md`.
- CQS05: Anti-Agentic-Slop Reviewer Skill. Add/update
  `.codex/skills/anti-agentic-slop-reviewer.md`.
- CQS06: Product Canon Drift Reviewer Skill. Add/update
  `.codex/skills/product-canon-drift-reviewer.md`.
- CQS07: Accessibility / Reduced Motion Reviewer Skill. Add/update
  `.codex/skills/accessibility-reduced-motion-reviewer.md`.
- CQS08: Privacy / Legal / App Store Reviewer Skill. Add/update
  `.codex/skills/privacy-legal-app-store-reviewer.md`.
- CQS09: Performance / Battery Reviewer Skill. Add/update
  `.codex/skills/performance-battery-reviewer.md`.
- CQS10: Platform Surface Reviewer Skill. Add/update
  `.codex/skills/platform-surface-reviewer.md`.
- CQS11: StoreKit / Monetization Reviewer Skill. Add/update
  `.codex/skills/storekit-monetization-reviewer.md`.
- CQS12: Schema / Sync / Migration Reviewer Skill. Add/update
  `.codex/skills/schema-sync-migration-reviewer.md`.
- CQS13: FAANG Handoff Reviewer Skill. Add/update
  `.codex/skills/faang-handoff-reviewer.md`.
- CQS14: Script: Prompt-Built Smell Scan. Add
  `scripts/cqs-prompt-built-smell-scan.sh`.
- CQS15: Script: Architecture Boundary Scan. Add
  `scripts/cqs-architecture-boundary-scan.sh`.
- CQS16: Script: Forbidden Product Drift Scan. Add
  `scripts/cqs-product-drift-scan.sh`.
- CQS17: Script: Privacy / Security / Legal Claim Scan. Add
  `scripts/cqs-privacy-security-claim-scan.sh`.
- CQS18: Script: Accessibility / Reduced Motion Coverage Scan. Add
  `scripts/cqs-accessibility-motion-scan.sh`.
- CQS19: Script: Preview / Screenshot Coverage Scan. Add
  `scripts/cqs-preview-coverage-scan.sh`.
- CQS20: Script: Performance Budget Scan. Add
  `scripts/cqs-performance-budget-scan.sh`.
- CQS21: Mature Repair Cycle Protocol. Formalize Recoverable Red vs Hard Red,
  repair loops, repair-batch splitting, accepted Yellow, and stop conditions.
- CQS22: Batch Report / PR Review Packet Template. Require FAANG-style packet
  evidence for every batch.
- CQS23: Global Orchestrator Integration. Update global orchestrator, order,
  dependency graph, registry, context, and run-state docs.
- CQS24: Codex OS Final Quality Gate. Define late-train quality gate before
  FCP28/PFC39/FCP29/PFC40/AOS27.

## Validation

CQS source-truth batches run `git status --short`, `git diff --check`,
touched-doc whitespace scans, `scripts/run-doc-qa.sh || true`, and
`scripts/batch-train-gate-check.sh || true`. Script batches also run
`shellcheck` when available and execute scripts in advisory mode.

## Output

Each CQS batch writes or updates an audit report, updates registry/context/
run-state when required, commits one batch at a time, and leaves the repo clean
before continuation.

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
