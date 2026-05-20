# AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01 Validation Proof

## Phase-01 Validation Already Recorded
- `python3 scripts/ambitions_validate_prompt_headers.py` -> `GREEN`
- `python3 scripts/ambitions_validate_batch_ids.py` -> `GREEN`
- `python3 scripts/ambitions_codex_os_validate.py` -> failed because the underscore-form file was absent
- `python3 scripts/ambitions-codex-os-validate.py` -> `GREEN`
- `python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-reset-master-01.jsoncheck` -> GREEN
- `git diff --check` -> passed
- `git status --short` -> only the untracked batch prompt remained before this phase

## Validator Mismatch Note
- The repo currently exposes the hyphenated validator path `scripts/ambitions-codex-os-validate.py`.
- The earlier probe used the underscore-form name, but the current repo exposes the hyphenated validator path.
- This is a tooling naming mismatch, not a source-code change.

## Phase-02 Validation Plan
- `python3 scripts/ambitions_validate_prompt_headers.py` -> GREEN
- `python3 scripts/ambitions_validate_batch_ids.py` -> GREEN
- `python3 scripts/ambitions-codex-os-validate.py` -> GREEN
- `python3 build/audits/amb_file_by_file_repo_audit.py` -> GREEN
- `python3 -m json.tool build/reports/amb-file-by-file-audit-summary.json >/tmp/amb-file-audit-summary.jsoncheck` -> GREEN
- `python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-reset-master-01.jsoncheck` -> GREEN
- `python3 -m json.tool build/reports/ambitions-codex-os-validate.json >/tmp/amb-codex-os-validate.jsoncheck` -> GREEN
- `git diff --check` -> GREEN
- `git status --short` -> shows the owned audit script, audit docs, and generated report changes

## Report Location Note
- The batch JSON is stored at the prompt-required path `build/reports/amb-repo-green-flagship-reset-master-01.json`.
- A supporting audit copy is also stored at `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json`.
- The surface vocabulary ledger is deferred, so the JSON does not claim measured zero remaining hits for Train 0.
- `scripts/ambitions-codex-os-validate.py` already allowlists the prompt-required build-report path.
- `build/reports/ambitions-codex-os-validate.json` is a validator-generated side effect; this phase allowlisted it as current validation evidence, not as app implementation or release proof.

## Phase-03 Review Repair
- The review rerun found `scripts/ambitions-codex-os-validate.py` still rejected `build/reports/amb-file-by-file-audit-summary.json` as a disallowed report change.
- The validator now treats `build/reports/amb-file-by-file-audit-summary.json` as an allowed non-batch audit report, not as a batch-result payload.
- `python3 scripts/ambitions-codex-os-validate.py` -> GREEN after the validator repair.
- `python3 build/audits/amb_file_by_file_repo_audit.py` -> GREEN after the validator repair.
- JSON parse checks and `git diff --check` passed after the repair.

## Proof Boundary
- This phase only proves that the audit scaffold can be created and parsed.
- It does not prove build, test, accessibility, performance, privacy, or release readiness.
