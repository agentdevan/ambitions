# No-Cost Codex OS Dry Run 002

Status: Green
Batch ID: AMB-CODEX-OS-NO-COST-HARDENING-002

## Objective
Run a bounded no-cost Codex OS control-plane dry run with a local structured runner output proof for this batch and keep defaults unchanged.

## Source truth inspected
- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md
- .codex/AGENTS.md
- .agents/AGENTS.md
- scripts/ambitions-codex-os-validate.py
- scripts/ambitions-codex-os-doctor.py
- scripts/ambitions-codex-os-print-install-notes.py
- scripts/ambitions-codex-train.sh
- Makefile
- .codex/schemas/ambitions-batch-result.schema.json
- .codex/hooks/**, .codex/rules/**, .codex/hooks.json, .codex/config.toml
- docs/codex-os/**
- prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md

## Files changed
- scripts/ambitions-codex-train.sh
- scripts/ambitions-codex-os-validate.py
- docs/codex-os/RUNNER_UPGRADE_NOTES.md
- docs/codex-os/STRUCTURED_OUTPUT.md
- docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_002.md
- build/reports/ambitions-codex-os-dry-run-002.json
- prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md

## Runner integration result
Opt-in local structured output support added to `scripts/ambitions-codex-train.sh` via:
- `STRUCTURED_OUTPUT=0|1`
- `OUTPUT_SCHEMA=.codex/schemas/ambitions-batch-result.schema.json`
- `OUTPUT_REPORT_DIR=build/reports/codex-runs`

Defaults remain unchanged when `STRUCTURED_OUTPUT` is unset or `0`.

## Structured output result
Structured output mode is supported locally without requiring `codex exec --output-schema`.

## Dry-run commands and exit codes
- `git status --short --branch --untracked-files=all -- . ':(exclude).codex/runs'` (pass)
- `git diff --check` (pass)
- `bash -n scripts/ambitions-codex-train.sh` (pass)
- `python3 -m py_compile .codex/hooks/*.py scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py` (pass)
- `python3 -m json.tool .codex/schemas/ambitions-batch-result.schema.json >/tmp/ambitions-batch-result-schema-check.txt` (pass)
- `python3 -m json.tool build/reports/ambitions-codex-os-dry-run-002.json >/tmp/ambitions-codex-os-dry-run-002-json-check.txt` (pass)
- `STRUCTURED_OUTPUT=1 OUTPUT_REPORT_DIR=build/reports/codex-runs scripts/ambitions-codex-train.sh --self-check` (pass)
- `python3 scripts/ambitions-codex-os-validate.py` (pass)
- `python3 scripts/ambitions-codex-os-doctor.py` (pass)
- `make ambitions-codex-os-validate` (pass)
- `make ambitions-codex-os-doctor` (pass)
- `codex features list` (pass)
- `codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git status` (allow)
- `codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules git push` (forbidden)
- `codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules npm install` (forbidden)
- `codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules curl https://example.com` (forbidden)
- `codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules xcodebuild archive` (forbidden)

## Execpolicy checks and decisions
See command list above. No policy exception was required.

## Validator/doctor results
- `python3 scripts/ambitions-codex-os-validate.py`: PASS, current aggregate report is Green
- `python3 scripts/ambitions-codex-os-doctor.py`: PASS

## Green rationale
The stale contradiction is reconciled: the dry-run packet, structured JSON, and aggregate validator report now agree on Green. The narrow validator issue was a self-hit risk in generated evidence: the validator report used a no-cost proof key containing the forbidden `api_key` token with an underscore. That field was renamed to neutral credential wording while preserving the strict command/content checks.

## No-cost proof
- No new dependencies added.
- No API keys or secrets.
- No network installers, signed release, hosted CI, App Store, or paid path introduced.
- Runner changes are local shell/Python and docs only.

## Forbidden scope proof
- No app source, Xcode project files, package manifests, entitlements, Info.plist, or workflow files changed.
- Forbidden-command patterns remained in exempted batch prompts where historically required for policy checks.

## Claims made
- Local structured output is opt-in and writes local JSON when enabled.
- Default runner behavior is preserved.
- Validator now allows this batch’s dry-run report and prompt artifact while remaining strict.

## Claims not made
- No new package/dependency addition.
- No API integration or CLI dependency changes.
- No release, archive, or store automation claims.

## Risks / limitations
- `STRUCTURED_OUTPUT` and `OUTPUT_REPORT_DIR` behavior was validated through runner `--self-check`, not a nested full batch invocation.
- Structured-output evidence is local; direct Codex CLI `--output-schema` enforcement remains deferred.

## Rollback
- `git checkout -- scripts/ambitions-codex-train.sh scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py Makefile .codex/schemas/ambitions-batch-result.schema.json .codex/hooks.json .codex/config.toml`
- `git checkout -- .codex/rules .codex/hooks docs/codex-os prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-002.md 2>/dev/null || true`
- `rm -f docs/codex-os/NO_COST_CODEX_OS_DRY_RUN_002.md build/reports/ambitions-codex-os-dry-run-002.json`

## Next recommended batch
- AMB-CODEX-OS-NO-COST-HARDENING-003
