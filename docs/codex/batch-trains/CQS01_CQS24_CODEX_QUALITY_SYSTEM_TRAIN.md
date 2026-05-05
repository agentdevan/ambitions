# CQS01-CQS24 Codex Quality System Train
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
