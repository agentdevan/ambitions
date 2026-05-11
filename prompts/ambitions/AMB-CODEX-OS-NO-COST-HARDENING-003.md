<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CODEX-OS-NO-COST-HARDENING-003 — No-Cost Codex OS Dirty-Work Classifier And Runner Quote Guard Adoption

## Batch ID

AMB-CODEX-OS-NO-COST-HARDENING-003

## Runner command

```bash
scripts/ambitions-codex-train.sh AMB-CODEX-OS-NO-COST-HARDENING-003 prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-003.md
```

Equivalent:

```bash
make batch BATCH=AMB-CODEX-OS-NO-COST-HARDENING-003 PROMPT=prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-003.md
```

## Objective

Run the next no-cost Codex OS hardening dry run after `AMB-CODEX-OS-NO-COST-HARDENING-002`.

This batch must:

1. Preserve `prompts/batches/MOAT-ALIGNMENT-01.md` as intentional out-of-band user canon work from another chat.
2. Do not edit, stage, classify as a defect, or validate the content of `prompts/batches/MOAT-ALIGNMENT-01.md`.
3. Repair/adopt only safe local runner quote-guard work that already exists in the working tree if it is validated and remains no-cost.
4. Update no-cost Codex OS validation so unrelated out-of-scope dirty prompt work can be reported as external dirty work without causing false Red for this Codex OS batch.
5. Keep structured runner output opt-in and local-only.
6. Produce an honest final report and local JSON proof for this batch.

## No-cost boundary

Do not add:

- API keys or secret wiring.
- model SDKs, MCP servers, local model runtimes, or app runtime AI dependencies.
- Network calls, `wget`, package-installer actions, hosted CI, hosted pipelines, signing, archive, upload, or app-store automation.
- New dependencies or paid-service paths.

Allowed implementation mechanisms:

- Local Markdown.
- Local JSON.
- Shell.
- Python standard library.
- Existing local runner scripts.

## Active source truth to inspect first

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
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_002.md
docs/codex-os/RUNNER_UPGRADE_NOTES.md
docs/codex-os/STRUCTURED_OUTPUT.md
.codex/schemas/ambitions-batch-result.schema.json
scripts/ambitions-codex-train.sh
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
scripts/ambitions-codex-os-print-install-notes.py
```

## Current dirty-work rule

`prompts/batches/MOAT-ALIGNMENT-01.md` is intentional new canon work being implemented in a different chat. Treat it as external dirty work.

This batch must not:

- edit it
- stage it
- commit it
- claim it is valid or invalid
- use it as proof for this batch
- force the no-cost validator to scan its policy terms as if it were this batch's control-plane change

If other dirty work exists, classify it before editing. Runner quote repair files may be adopted only if they are no-cost, local-only, and validated.

## Allowed scope

This batch may modify only:

```text
scripts/ambitions-codex-train.sh
scripts/ambitions-runner-quote-self-check.sh
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
scripts/ambitions-codex-os-print-install-notes.py
Makefile
docs/codex-os/**
build/reports/ambitions-codex-os-dry-run-003.json
prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-003.md
prompts/batches/RUNNER-QUOTE-REPAIR-01.md
```

## Forbidden scope

Do not modify:

```text
prompts/batches/MOAT-ALIGNMENT-01.md
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
```

Do not run or continue `MOAT-ALIGNMENT-01` in this batch.

## Required implementation

1. Inspect current dirty work and document it in the final report.
2. If a runner quote guard patch is present, validate it and either:
   - keep it if it passes and stays inside this batch scope, or
   - remove only the quote-guard changes if they fail or are unsafe.
3. Update the no-cost validator so it distinguishes:
   - batch-owned Codex OS files that must be scanned strictly
   - explicitly external dirty prompt work that must be reported but not treated as this batch's no-cost failure
4. Keep hard failures for actual batch-owned cost exposure.
5. Preserve strict failures for app source, dependency manifests, pipeline files, signing, network installers, API-key wiring, and package-install additions inside this batch.
6. Add/update dry-run proof:

```text
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_003.md
build/reports/ambitions-codex-os-dry-run-003.json
```

7. Mention that `MOAT-ALIGNMENT-01` remains uncommitted external work and was not modified.

## Required validation

Run:

```bash
git status --short --branch --untracked-files=all -- . ':(exclude).codex/runs'
git diff --check
bash -n scripts/ambitions-codex-train.sh
bash -n scripts/ambitions-runner-quote-self-check.sh
python3 -m py_compile .codex/hooks/*.py scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py
python3 -m json.tool .codex/schemas/ambitions-batch-result.schema.json >/tmp/ambitions-batch-result-schema-check.txt
python3 -m json.tool build/reports/ambitions-codex-os-dry-run-003.json >/tmp/ambitions-codex-os-dry-run-003-json-check.txt
scripts/ambitions-codex-train.sh --self-check
scripts/ambitions-codex-train.sh --quote-self-check
python3 scripts/ambitions-codex-os-doctor.py
python3 scripts/ambitions-codex-os-validate.py
make ambitions-codex-os-doctor
make ambitions-codex-os-validate
```

If `--quote-self-check` is not available after inspection and adding it would be unsafe, document that limitation as Accepted Yellow. Do not fabricate proof.

Run representative execpolicy checks if available:

```bash
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git status
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules install-package
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules http-probe
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules archive-build-command
```

## Green / Yellow / Red policy

Green is allowed only if:

- no forbidden scope files were modified
- the MOAT prompt remains untouched and unstaged
- runner quote guard passes, if adopted
- validator passes despite unrelated external dirty MOAT prompt
- doctor passes
- no-cost proof is clean

Accepted Yellow is allowed if:

- the only remaining issue is out-of-band dirty work, optional execpolicy availability, or an intentionally deferred structured-output CLI feature
- all batch-owned files validate
- the final report is explicit

Red is required if:

- this batch modifies `MOAT-ALIGNMENT-01.md`
- this batch modifies app source, dependency/signing, or pipeline files
- cost exposure is introduced
- validator is weakened so real batch-owned cost exposure can pass silently
- runner quote repair is unsafe or broad

## Commit policy

Stage only this batch's owned files. Do not stage:

```text
prompts/batches/MOAT-ALIGNMENT-01.md
.codex/runs/**
```

Commit message:

```text
AMB-CODEX-OS-NO-COST-HARDENING-003: classify external prompt work
```

Push to `origin/main` only after validation and final report evidence are honest.

## Final response requirements

Report:

```text
Status: Green / Accepted Yellow / Red
Batch ID
Commit SHA, if committed
Files changed
Runner quote guard result
Validator scoping result
Validation summary
No-cost proof
External dirty work preserved
Claims not made
Risks / limitations
Rollback
Next recommended batch
```
