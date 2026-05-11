# Ambitions No-Cost Rules Policy

This file documents local Codex command policy in `.codex/rules/ambitions-no-cost.rules`.

## What is allowed

- Git status/diff/revision lookup, `rg`, `find`, `ls`, `cat`, `sed`, `awk`.
- Local validation execution of `python3 scripts/ambitions-codex-os-validate.py` and `python3 scripts/ambitions-codex-os-doctor.py`.
- Make targets for the same commands.

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
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push
```

When `codex execpolicy` is unavailable, treat this as Yellow verification risk and continue with manual review.
