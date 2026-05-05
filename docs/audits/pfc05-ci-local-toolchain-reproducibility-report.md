# PFC05 CI / Local Toolchain Reproducibility Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance
Batch: PFC05

## Result

PFC05 completed as a narrow tooling/docs batch. It adds a local CI parity wrapper
that runs the repo's existing evidence-producing validation steps in a stable
order, writes an ignored log under `output/logs/`, keeps native build and full
test lanes opt-in, and repeats the existing no-release-claim boundary. It did
not edit production Swift, shared packages, tests, previews, project generation,
GitHub Actions workflows, dependencies, Brewfiles, signing, entitlements,
privacy manifests, lockfiles, or generated output.

## Source Truth Used

- `README.md`
- `AGENTS.md`
- `scripts/validate-dev-tools.sh`
- `scripts/build-local.sh`
- `scripts/test-local.sh`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`
- `.github/workflows/ios-validate.yml`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
- `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc04-dependency-supply-chain-policy-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `scripts/ci-local-parity.sh`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
- `docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md`
- `docs/codex/batches/PFC05_CI_Local_Toolchain_Reproducibility_Prompt.md`
- `docs/audits/pfc05-ci-local-toolchain-reproducibility-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Local CI Parity Wrapper

`scripts/ci-local-parity.sh` now provides a single local entry point for
repeatable validation evidence.

Default steps:

- `git status --short`
- `scripts/validate-dev-tools.sh`
- `xcodegen generate`
- `git diff --check`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`

Opt-in steps:

- `RUN_BUILD=1 scripts/ci-local-parity.sh` runs `scripts/build-local.sh`.
- `RUN_TESTS=1 scripts/ci-local-parity.sh` runs `scripts/test-local.sh`.
- `RUN_DOC_QA=0` skips docs QA for focused script dry runs.
- `RUN_GATE=0` skips the batch gate wrapper for focused script dry runs.

The wrapper records step pass/fail lines and preserves exit status. It does not
delete files, stage files, install tools, edit workflows, or claim release
readiness.

## Runbook Updates

The Mac Codex toolchain setup guide now names `scripts/ci-local-parity.sh` as
the local CI parity wrapper and explains the opt-in build/test flags. The local
toolchain readiness matrix now includes the wrapper as an adopted local script
instead of a new dependency.

## Remaining Yellow Items

| Item | Owner | Repair path |
| --- | --- | --- |
| CI workflow still installs XcodeGen via unpinned Homebrew formula. | PFC05/PFC39 CI owner | Future workflow hardening may pin tools/actions if workflow edits are explicitly scoped. |
| GitHub Actions use major-version tags. | PFC05/PFC39 CI owner | Pin action SHAs only in a workflow-authorized batch. |
| Full `scripts/test-local.sh` can include known UI smoke debt. | QA / UI reliability owners | Keep full tests opt-in and classify failures rather than upgrading readiness claims. |
| Doc QA still has existing markdown/deprecated-language backlog. | Docs/CQS owners | Continue advisory treatment until a dedicated cleanup batch reduces the backlog. |

## Non-Claims

PFC05 does not claim CI is perfectly reproducible, workflows are hardened,
Xcode/Homebrew/GitHub Actions are pinned, UI smoke is clean, release readiness,
TestFlight readiness, App Store readiness, physical-device proof, public
accessibility conformance, legal/privacy signoff, or FAANG handoff readiness.

## Validation

Commands required for PFC05:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `bash -n scripts/ci-local-parity.sh`
- `RUN_DOC_QA=0 RUN_GATE=0 scripts/ci-local-parity.sh`
- `scripts/validate-dev-tools.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Result summary:

- `git status --short`: expected dirty tree before commit.
- `git diff --check`: PASS.
- Touched-doc trailing whitespace scan: PASS.
- `bash -n scripts/ci-local-parity.sh`: PASS.
- `RUN_DOC_QA=0 RUN_GATE=0 scripts/ci-local-parity.sh`: PASS. The wrapper ran
  status, tool validation, `xcodegen generate`, and diff check, then skipped
  docs QA and gate by flag.
- `scripts/validate-dev-tools.sh || true`: PASS in advisory mode; optional
  staged tools may remain optional.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Existing stale-guidance,
  deprecated-language, and markdownlint backlog remains; lychee reports no link
  errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only
  current hint is expected dirty-worktree state before commit.
- No full build/test command was required because PFC05 did not change app code,
  project shape, dependencies, or workflows.

## Rollback Path

Revert the PFC05 commit to remove the local CI parity wrapper, runbook updates,
generated prompt, report, and associated train-state updates. No app behavior or
CI workflow rollback is needed because PFC05 changes no production code or
workflow/config source truth.

## Next Eligible Batch

PFC06 Schema And Persistence Source Truth is the next eligible full-stack batch
under `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` after PFC05 closes.
