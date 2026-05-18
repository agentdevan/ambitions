# AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01

Status: supporting install report

Supporting note: This report documents a docs/control-plane-only install layer.
It does not override `docs/truth/*`.

## Summary

Installed a subordinate ChatGPT-to-Codex handoff layer under
`docs/codex/chatgpt/` and added matching prompt templates under
`prompts/templates/` without changing app source, runner scripts, or active
canon.

## Existing repo OS paths discovered

- `docs/truth/README.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/os/README.md`
- `.codex/README.md`
- `docs/governance/CODEX_OS_INTEGRATION.md`
- `docs/governance/GOVERNANCE_DASHBOARD.md`
- `docs/governance/AUTONOMY_COMMANDS.md`
- `prompts/_BATCH_TEMPLATE.md`
- `prompts/templates/AMBITIONS_REMAINING_BATCH_EXECUTION_STANDARD.md`

## ChatGPT OS artifacts installed

- `docs/codex/chatgpt/README.md`
- `docs/codex/chatgpt/AMB-CHATGPT-HANDOFF-OS.md`
- `docs/codex/chatgpt/AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD.md`
- `docs/codex/chatgpt/AMB-CHATGPT-REPO-QUESTION-PATTERNS.md`
- `docs/codex/chatgpt/AMB-CHATGPT-DECISION-LOG-STANDARD.md`
- `docs/codex/chatgpt/AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md`
- `docs/codex/chatgpt/AMB-CHATGPT-FLAGSHIP-BAR.md`
- `docs/codex/chatgpt/AMB-CHATGPT-CODEX-HANDOFF-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-UI-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-BACKEND-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-APPLE-CONTINUITY-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-APP-STORE-HONESTY-PROMPT-TEMPLATE.md`
- `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-BOARD-STANDARD.md`

## Templates installed

- `prompts/templates/ambitions-runner-batch-template.md`
- `prompts/templates/ambitions-audit-template.md`
- `prompts/templates/ambitions-repair-template.md`
- `prompts/templates/ambitions-ui-flagship-template.md`
- `prompts/templates/ambitions-backend-local-first-template.md`
- `prompts/templates/ambitions-apple-continuity-template.md`
- `prompts/templates/ambitions-launch-gate-template.md`

## Decision log installed or updated

- `docs/codex/chatgpt/AMB-CHATGPT-LAUNCH-SCOPE-DECISIONS.md`

The log keeps `Time` as active top-level IA and treats `Plan` as an internal
compatibility seam only where active truth allows it.

## Review boards installed or updated

- `docs/codex/chatgpt/AMB-CHATGPT-REVIEW-BOARD-STANDARD.md`

The standard covers the eight required review-board categories and points back
to existing `.codex/review-boards/` operational precedent rather than creating
a competing repo OS.

## Validation

- `git diff --check` passed.
- `rg -n "[ \t]+$" docs/codex/chatgpt docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md prompts/templates/ambitions-*.md prompts/batches/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md` found no trailing whitespace in the installed docs/templates/prompt.
- `make batch-self-check` passed Green.
- `make prompt-audit` returned Yellow as expected for prompt-like
  support/eval/template files; no active runnable prompt was missing metadata.
- `python3 scripts/ambitions-codex-os-validate.py` passed Green.
- `build/reports/ambitions-codex-os-validate.json` was restored after validation
  so generated report churn is not part of this install.

No app build, simulator test, device test, accessibility proof run, privacy
review, continuity proof, TestFlight validation, or App Store validation was run
because this is a docs/control-plane-only install.

## Risks

The main risk is duplication if future work starts treating `docs/codex/chatgpt/`
as an authority root instead of a support layer. That risk is controlled here by
linking back to `docs/truth/*` and the existing Codex OS docs.

## Worktree hygiene

Current branch is `main` at `0d90ad8270f0caadcd556f543549ae3d26d244f9`.
This pass remained path-limited to the approved docs/template additions, the
batch prompt, and this report file. A separate untracked prompt,
`prompts/batches/AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01.md`, is present and
was not inspected as part of this batch scope. No app source, runner script,
active truth file, project file, package manifest, or generated run directory
was changed.

## Rollback

Path-limited restore:

```bash
git restore -- docs/codex/chatgpt docs/codex/reports/AMB-CHATGPT-REPO-OS-UPGRADE-INSTALL-01.md prompts/templates
```

If the new files need to be removed instead of restored, delete only the
approved new paths.

## Recommended next command

```bash
git diff --check
```
