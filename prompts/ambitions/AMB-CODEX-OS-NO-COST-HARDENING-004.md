<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CODEX-OS-NO-COST-HARDENING-004 - Path-Limited Git Add Approval And Scoped Dry-Run Closeout

## Batch ID

AMB-CODEX-OS-NO-COST-HARDENING-004

## Runner command

```bash
scripts/ambitions-codex-train.sh AMB-CODEX-OS-NO-COST-HARDENING-004 prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-004.md
```

Equivalent:

```bash
make batch BATCH=AMB-CODEX-OS-NO-COST-HARDENING-004 PROMPT=prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-004.md
```

## Objective

Finish the no-cost Codex OS hardening chain by making path-limited staging usable in normal Codex OS sessions while preserving the repo's prohibition on broad staging, destructive git commands, hosted CI, network/package installs, API keys, and app/runtime dependency changes.

This batch must also close out the already-created no-cost dry-run 003 artifacts if they remain uncommitted in the working tree.

## Required current-state handling

- `origin/main` already contains the separate MOAT commit.
- `prompts/batches/VISUAL-CANON-MOAT-01.md` may exist as unrelated external dirty work from another chat. Do not edit, stage, validate, or claim it.
- Existing Codex OS 003 files may already exist and may be included in this batch's closeout if they are unchanged in purpose and pass validation:
  - `scripts/ambitions-codex-os-validate.py`
  - `docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_003.md`
  - `build/reports/ambitions-codex-os-dry-run-003.json`
  - `prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-003.md`

## No-cost boundary

Do not add:

- API keys, secret wiring, hosted CI, GitHub Actions, remote runners, network downloads, package installs, new dependencies, signing/archive/upload automation, MCP servers, paid services, or app runtime OpenAI/cloud model dependencies.

Allowed:

- Local Markdown.
- Local JSON.
- Local shell.
- Python standard library.
- Repo-local Codex rules/docs/scripts.
- Existing Ambitions runner.

## Active source truth to inspect

Read before editing:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
.codex/AGENTS.md
.agents/AGENTS.md
docs/codex-os/NO_COST_CODEX_OS.md
docs/codex-os/RULES_POLICY.md
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_003.md
.codex/rules/ambitions-no-cost.rules
.codex/schemas/ambitions-batch-result.schema.json
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
scripts/ambitions-codex-train.sh
```

## Allowed scope

This batch may modify only:

```text
.codex/rules/ambitions-no-cost.rules
docs/codex-os/RULES_POLICY.md
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_003.md
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_004.md
build/reports/ambitions-codex-os-dry-run-003.json
build/reports/ambitions-codex-os-dry-run-004.json
scripts/ambitions-codex-os-validate.py
prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-003.md
prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-004.md
```

## Forbidden scope

Do not modify:

```text
Native/**
Sources/**
AppUI/**
project.yml
Package.swift
.github/**
entitlements
signing files
lockfiles
secrets
prompts/batches/VISUAL-CANON-MOAT-01.md
.codex/runs/**
```

## Required implementation

1. Change `.codex/rules/ambitions-no-cost.rules` so path-limited `git add` is allowed for local Codex OS closeout.
2. Keep broad staging forbidden by hook/policy language:
   - `git add .`
   - `git add -A`
   - `git commit -a`
3. Preserve `git commit` as prompt-level or approval-level behavior.
4. Preserve `git push` as forbidden in no-cost local rules unless a future explicit batch changes release/git mutation policy.
5. Update `docs/codex-os/RULES_POLICY.md` to explain that `git add` is allowed only for exact path-limited staging and that broad staging remains blocked.
6. Ensure the validator knows the 004 dry-run report is an allowed report path.
7. Create:

```text
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_004.md
build/reports/ambitions-codex-os-dry-run-004.json
```

8. If existing 003 files are still dirty, include them as prior dry-run artifacts completed by this closeout, but do not broaden their scope.

## Required validation

Run:

```bash
git status --short --branch --untracked-files=all -- . ':(exclude).codex/runs'
git diff --check
python3 -m json.tool build/reports/ambitions-codex-os-dry-run-004.json >/tmp/ambitions-codex-os-dry-run-004-json-check.txt
python3 -m py_compile .codex/hooks/*.py scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py
python3 scripts/ambitions-codex-os-doctor.py
AMBITIONS_CODEX_OS_EXTERNAL_DIRTY_PATHS="prompts/batches/VISUAL-CANON-MOAT-01.md" python3 scripts/ambitions-codex-os-validate.py
make ambitions-codex-os-doctor
AMBITIONS_CODEX_OS_EXTERNAL_DIRTY_PATHS="prompts/batches/VISUAL-CANON-MOAT-01.md" make ambitions-codex-os-validate
```

Run representative execpolicy checks if available:

```bash
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git status
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git add -- docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_004.md
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git commit
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules npm install
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules curl https://example.com
```

Record exact outcomes honestly.

## Green / Yellow / Red policy

Green is allowed if:

- path-limited `git add` resolves to allow
- broad staging remains documented as forbidden
- validation passes with only operator-classified external dirty prompt work excluded
- no forbidden-cost or forbidden-scope files are modified
- final report and JSON proof exist

Accepted Yellow is allowed if:

- `codex execpolicy check` cannot express broad-staging examples exactly, but docs/hooks/runner still block broad staging and local validation passes

Red is required if:

- app source, dependency files, CI, signing, secrets, or network/package install paths are modified
- `git push` becomes allowed by the no-cost rules
- broad staging is permitted without a guard
- cost exposure is introduced

## Commit policy

Stage only this batch's owned files. Do not stage:

```text
prompts/batches/VISUAL-CANON-MOAT-01.md
.codex/runs/**
```

Commit message:

```text
AMB-CODEX-OS-NO-COST-HARDENING-004: approve path-limited staging
```

## Final response requirements

Report:

```text
Status: Green / Accepted Yellow / Red
Batch ID
Commit SHA, if committed
Files changed
Git add policy result
Validation summary
No-cost proof
External dirty work preserved
Claims not made
Risks / limitations
Rollback
Next recommended batch
```
