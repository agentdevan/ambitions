# FET00 FAANG Frontend Codex OS Upgrade Prompt

<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: CQS25 / FET00
- Title: FAANG Frontend Codex OS Upgrade
- Train: FET01-FET12 FAANG Frontend Excellence Train setup
- Type: Codex OS improvement; docs/tooling/reviewer skills only
- Status: Complete after CQS25/FET00 validation and commit

## Purpose

Upgrade Ambitions Codex OS so future frontend implementation behaves like a senior FAANG / Apple-caliber iOS product engineering team rather than a generic batch executor. The upgrade blocks the failure mode where SwiftUI builds pass but the live simulator UI still looks like stacked generic panels, diagnostic cards, or over-explained compliance UI.

## Source Truth To Inspect

- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batches/SI16_Preview_Fixture_And_Visual_QA_Infrastructure_Prompt.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/canon/Ambitions_Visual_QA_Red_Team_Audit.md`
- `.codex/skills/**`
- `scripts/si-*.sh`

## Allowed Files

- `docs/codex/**`
- `docs/audits/**`
- `.codex/skills/**`
- `scripts/fet-*.sh`

## Forbidden Files

- Production Swift app UI or behavior
- route/raw values
- persistence/schema
- workflows/hosted CI
- signing/entitlements
- dependency manifests or lockfiles
- release, App Store, TestFlight, device, legal/privacy, public accessibility, or visual approval claims

## Required Outputs

- `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md`
- `docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md`
- `docs/codex/batch-trains/FET01_FET12_FAANG_FRONTEND_EXCELLENCE_TRAIN.md`
- `docs/codex/batches/FET00_FAANG_FRONTEND_CODEX_OS_UPGRADE_PROMPT.md`
- `docs/audits/fet00-faang-frontend-codex-os-upgrade-report.md`
- FET reviewer skills under `.codex/skills/`
- FET advisory scripts under `scripts/`
- integration updates to global gate protocol, registry, global order, and gate matrix

## Green Criteria

- Required docs, skills, and scripts exist.
- Global protocol requires FET readiness for UI-touching batches.
- Registry marks CQS25/FET00 complete only after validation.
- Global order inserts FET before further visible top-level UI expansion without breaking existing SI/CQS/AFI/FCP/PD ordering truth.
- Future FCP/AFI/DAV/PD UI batches inherit FET gates.
- Validation output is recorded in the FET00 report.
- No app feature implementation, route/raw-value, persistence/schema, workflow, signing, dependency, or release-claim change is made.

## Yellow Criteria

- Advisory scripts report existing broad UI/copy/primitive hits that require later human or interface-recovery owners.
- Doc QA reports pre-existing markdown/history backlog, with no introduced hard Red.
- Screenshot packet scan reports no current FET packet for this docs-only batch and the batch makes no current UI-fix claim.

## Red Criteria

- App UI behavior changes.
- Existing gates are weakened or source-truth history is removed.
- FET Green is claimed for current rendered UI.
- Route/raw values, persistence/schema, workflows, signing, dependencies, or release claims change.
- Required FET source-truth files, skills, scripts, or integration updates are missing.

## Validation

```bash
git status --short
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
scripts/fet-readiness-gate.sh || true
scripts/fet-first-viewport-budget-scan.sh || true
scripts/fet-bottom-chrome-conflict-scan.sh || true
scripts/fet-primitive-density-scan.sh || true
scripts/fet-copy-density-scan.sh || true
scripts/fet-visual-qa-packet-check.sh || true
```

## Commit Message

Upgrade Codex OS with FAANG frontend gates

## Non-Claims

FET00 does not claim the current UI is fixed, visually approved, accessibility approved, release-ready, TestFlight-ready, App Store-ready, or device-proven.
