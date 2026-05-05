# PFC04 Dependency And Supply Chain Policy Enforcement Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Platform / Framework / Compliance batch; generated from the
PFC manifest because the global order selected PFC04 and no standalone prompt
previously existed.

## Batch Identity

- Batch ID: `PFC04`
- Name: Dependency And Supply Chain Policy Enforcement
- Train: PFC Platform / Framework / Compliance
- Type: Audit/docs
- Owner: Platform / Security

## Purpose

Inventory runtime dependencies, local tool dependencies, GitHub Actions, lockfile
posture, privacy manifests, entitlements, SDK/privacy risk, and supply-chain
policy gaps. PFC04 creates an enforcement ledger only; it does not change
dependencies, workflows, signing, project generation, or production code.

## Source Truth

- `README.md`
- `AGENTS.md`
- `Package.swift`
- `project.yml`
- `.github/workflows/ios-validate.yml`
- `Brewfile`
- `Brewfile.optional-later`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/canon/Ambitions_3_0_Dependency_Promotion_Ladder.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc02-architecture-boundary-module-map-report.md`
- `docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md`
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
- `Brewfile`
- `Brewfile.optional-later`
- lockfiles
- signing, entitlement, provisioning, workflow, dependency, generated build, and
  Xcode project files

## Required Deliverables

- PFC04 supply-chain and dependency ledger.
- Runtime dependency and local tooling classification.
- Privacy manifest / SDK / required-reason API review list.
- License and action-pinning risk table.
- Updated registry/context/run-state/global order after validation.

## Validation

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-privacy-security-claim-scan.sh . || true`
- `rg --files | rg 'Package.resolved|Podfile.lock|Cartfile.resolved|Gemfile.lock|PrivacyInfo.xcprivacy|entitlements' || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

No build/test command is required unless PFC04 changes production code or
project configuration, which it must not do.

## Green / Yellow / Red

Green: docs-only dependency ledger is complete, no dependency/config/workflow
edits are made, and supply-chain gaps are classified with owners.

Yellow: unpinned GitHub Actions/Homebrew tools, empty or incomplete privacy
manifest review, missing license documentation, or future SDK review backlog is
documented with owner and repair path.

Red: new dependency, workflow, signing, entitlement, project, privacy manifest,
or production source edit; secret exposure; unsupported legal/privacy/release
claim; or a required supply-chain decision that cannot be resolved from repo
truth.

## Commit Message

`PFC04: Add dependency supply chain ledger`
