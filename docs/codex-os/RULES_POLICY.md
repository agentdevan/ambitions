# Ambitions No-Cost Rules Policy

This file documents local Codex command policy in `.codex/rules/ambitions-no-cost.rules`.

## What is allowed

- Git status/diff/revision lookup, `rg`, `find`, `ls`, `cat`, `sed`, `awk`.
- Local validation execution of `python3 scripts/ambitions-codex-os-validate.py` and `python3 scripts/ambitions-codex-os-doctor.py`.
- Make targets for the same commands.
- Safe local Xcode validation through Ambitions-owned wrapper entrypoints:
  - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane build`
  - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane build-for-testing`
  - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane focused-test`
  - `scripts/ambitions-xcode-validate.sh --batch <BATCH> --lane test-plan`
  - `make xcode-validate BATCH=<BATCH> LANE=<lane>`
  - `make xcode-focused-test BATCH=<BATCH> TEST=<test-id>`
  - `make xcode-build-for-testing BATCH=<BATCH>`
  - `make xcode-test-plan BATCH=<BATCH> TEST_PLAN=<plan-name>`
  - `make build-lab-doctor`

## Xcode validation policy

The runner should allow wrapper-mediated Xcode validation because source-touching SwiftUI, SwiftData, runtime, persistence, project, entitlement, and test batches need compile/test proof.

Safe Xcode validation must remain local-only and proof-oriented:

- Use Ambitions wrappers and Make targets as the default entrypoints.
- Use repo-local DerivedData/result/log/summary roots defined by the Xcode Build Lab Protocol.
- Disable signing for local compile lanes.
- Capture logs and summaries for batch proof.
- Do not claim release readiness from local validation alone.

Raw `xcodebuild` remains prompt-level unless explicitly routed through approved wrappers. Archive/export/signing/upload commands remain forbidden.

## What is prompted or blocked

- Networked or package-install commands such as `curl`, `wget`, `npm/pnpm/yarn install`, `pip install`, `brew install`.
- Cost/policy-sensitive commands such as `git push`, `gh workflow`, `xcodebuild archive`, signing helpers, and destructive resets.
- Staging for Codex OS closeout is allowed only when path-limited:
  - `git add -- <owned-path>` (for example: `git add -- docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_004.md`).
- Broad staging patterns remain blocked:
  - `git add .`
  - `git add -A`
  - `git add -a`
  - `git commit -a`
- Commit remains prompt-level approval: `git commit`.
- `git push` and network/package/signing/archive/upload commands remain forbidden.
- The rules are guardrails only and do not replace validator checks.

## Usage

Test guardrails with:

```bash
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git status
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules scripts/ambitions-xcode-validate.sh --batch TEST --lane build
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules make xcode-validate BATCH=TEST LANE=build
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules xcodebuild archive
```

When `codex execpolicy` is unavailable, treat this as Yellow verification risk and continue with manual review.