<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CODEX-OS-NO-COST-HARDENING-002

## Batch ID

AMB-CODEX-OS-NO-COST-HARDENING-002

## Runner command

```bash
scripts/ambitions-codex-train.sh AMB-CODEX-OS-NO-COST-HARDENING-002 prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md
```

Equivalent:

```bash
make batch BATCH=AMB-CODEX-OS-NO-COST-HARDENING-002 PROMPT=prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md
```

## Operating mode

Run through the Ambitions runner only:

```text
GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit
```

Direct pasted Codex execution is forbidden unless the user explicitly says: `bypass the Ambitions runner`.

## Objective

Run a no-cost Codex OS dry run and adopt structured runner output only where the existing runner can support it safely.

This batch must:

1. Verify the local Codex OS assets created by `AMB-CODEX-OS-NO-COST-HARDENING-001`.
2. Exercise the local validator, doctor, hooks/rules/schema checks, and representative execpolicy checks without adding cost exposure.
3. Add a durable local dry-run evidence report.
4. Add or update runner structured-output support only if the existing `scripts/ambitions-codex-train.sh` can support it with a small backward-compatible opt-in patch.
5. Preserve current default runner behavior when the new structured-output option is not enabled.

## No-cost boundary

Hard rule: local repo files only.

Forbidden:

- API keys.
- OpenAI SDK or Agents SDK dependency.
- MCP server additions.
- GitHub Actions or hosted CI.
- Package installs or new package dependencies.
- Network downloads.
- App runtime cloud/LLM dependencies.
- Signing, archive, App Store upload, TestFlight, or release automation.
- Secrets.
- App source behavior changes.

Allowed:

- Local Markdown, JSON, TOML, shell, and Python standard library scripts.
- Existing local Codex CLI invocation through the Ambitions runner.
- Existing local validation commands.
- Minimal backward-compatible runner changes.

## Active source truth to inspect first

Inspect:

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
docs/codex-os/CODEX_OS_COMPONENTS.md
docs/codex-os/RUNNER_UPGRADE_NOTES.md
docs/codex-os/STRUCTURED_OUTPUT.md
docs/codex-os/RULES_POLICY.md
docs/codex-os/HOOKS_POLICY.md
.codex/schemas/ambitions-batch-result.schema.json
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
scripts/ambitions-codex-train.sh
Makefile
```

## Required preflight

Run:

```bash
git status --short --branch --untracked-files=all -- . ':(exclude).codex/runs'
git diff --check
python3 scripts/ambitions-codex-os-validate.py
python3 scripts/ambitions-codex-os-doctor.py
make ambitions-codex-os-validate
make ambitions-codex-os-doctor
codex features list
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git status
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules npm install
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules curl https://example.com
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules xcodebuild archive
```

If `codex execpolicy` is unavailable, record Accepted Yellow only if the validator/doctor still pass and no hard no-cost policy is violated.

## Allowed scope

You may modify only:

```text
scripts/ambitions-codex-train.sh
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
scripts/ambitions-codex-os-print-install-notes.py
Makefile
.codex/schemas/**
.codex/rules/**
.codex/hooks/**
.codex/hooks.json
.codex/config.toml
docs/codex-os/**
build/reports/**
prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md
```

Do not modify app source, Xcode project files, package manifests, lockfiles, entitlements, signing files, workflows, or secrets.

## Structured runner output requirements

Inspect `scripts/ambitions-codex-train.sh`. Patch it only if the change is small, backward-compatible, no-cost, and opt-in.

Preferred safe support:

1. Add optional environment variables:
   - `STRUCTURED_OUTPUT=0|1`
   - `OUTPUT_SCHEMA=.codex/schemas/ambitions-batch-result.schema.json`
   - `OUTPUT_REPORT_DIR=build/reports/codex-runs`
2. Preserve existing defaults:
   - current runner behavior remains unchanged when `STRUCTURED_OUTPUT` is unset or `0`.
   - no API-key path.
   - no hosted CI.
   - no package install.
   - no signing/archive/release path.
3. If `STRUCTURED_OUTPUT=1`:
   - create `OUTPUT_REPORT_DIR` locally.
   - write or copy a final structured JSON summary for the batch using the existing local schema fields.
   - include batch id, status, changed files, validation evidence pointers, no-cost proof, source truth, risks, rollback, and next recommended batch.
   - do not require Codex CLI schema mode if the installed CLI does not support it.
4. If direct `codex exec --output-schema` support is ambiguous or unsupported, do not force it. Use local post-run JSON summary generation instead and document that schema-mode Codex output remains deferred.

If runner integration is unsafe or ambiguous, do not patch the runner. Instead, update `docs/codex-os/RUNNER_UPGRADE_NOTES.md` with the exact reason and close Accepted Yellow if all other dry-run proof passes.

## Dry-run report

Create:

```text
docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_002.md
```

It must include:

```text
Status: Green / Accepted Yellow / Red
Batch ID
Objective
Source truth inspected
Files changed
Runner integration result
Structured output result
Dry-run commands and exit codes
Execpolicy checks and decisions
Validator/doctor results
No-cost proof
Forbidden scope proof
Claims made
Claims not made
Risks / limitations
Rollback
Next recommended batch
```

Also write a local structured batch result JSON at:

```text
build/reports/ambitions-codex-os-dry-run-002.json
```

The JSON should conform to `.codex/schemas/ambitions-batch-result.schema.json`.

## Validator update

Update `scripts/ambitions-codex-os-validate.py` only as needed to:

- allow this batch's dry-run report JSON under `build/reports/`.
- validate the runner structured output summary if added.
- keep `AMB-CODEX-OS-NO-COST-HARDENING-001` validation intact.
- keep forbidden scope/no-cost scans strict.

## Validation requirements

Run:

```bash
git diff --check
bash -n scripts/ambitions-codex-train.sh
python3 -m py_compile .codex/hooks/*.py scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py
python3 -m json.tool .codex/schemas/ambitions-batch-result.schema.json >/tmp/ambitions-batch-result-schema-check.txt
python3 scripts/ambitions-codex-os-validate.py
python3 scripts/ambitions-codex-os-doctor.py
make ambitions-codex-os-validate
make ambitions-codex-os-doctor
codex features list
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git status
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules npm install
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules curl https://example.com
codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules xcodebuild archive
```

If runner structured-output mode is patched, also run a no-op local smoke command that does not spawn a nested Ambitions batch from inside the active runner. Prefer script syntax/self-check and local JSON summary validation over nested runner execution.

## Green conditions

Report Green only if:

- dry-run report exists.
- dry-run JSON exists and conforms to schema.
- validator passes.
- doctor passes.
- runner patch, if made, is syntax-valid and opt-in.
- default runner behavior remains unchanged.
- no no-cost policy violation exists.
- no forbidden scope file changed.

## Accepted Yellow conditions

Accepted Yellow is allowed if:

- all local control-plane checks pass, and
- the only deferred item is direct Codex CLI `--output-schema` support or full structured runner adoption because current runner/CLI behavior makes it unsafe to force.

## Hard Red conditions

Stop Red if:

- any app source/project/signing/workflow/dependency file is modified.
- any API key, SDK, package install, hosted CI, external service, network download, or paid path is introduced.
- runner default behavior changes unexpectedly.
- validator/doctor cannot run.
- structured output would require unsafe runner mutation.

## Final response

End with:

```text
Status: Green / Accepted Yellow / Red
Batch ID
Commit SHA, if committed
Files changed
Runner integration result
Structured output result
Validation summary
No-cost proof
Claims not made
Risks / limitations
Rollback
Next recommended batch
```
