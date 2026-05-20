# AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01 Validation Proof

## Phase-01 Validation Already Recorded
- `python3 scripts/ambitions_validate_prompt_headers.py` -> `GREEN`
- `python3 scripts/ambitions_validate_batch_ids.py` -> `GREEN`
- `python3 scripts/ambitions_codex_os_validate.py` -> failed because the underscore-form file was absent
- `python3 scripts/ambitions-codex-os-validate.py` -> `GREEN`
- `git diff --check` -> passed
- `git status --short` -> only the untracked batch prompt remained before this phase

## Validator Mismatch Note
- The repo currently exposes the hyphenated validator path `scripts/ambitions-codex-os-validate.py`.
- The underscore-form path expected by the earlier probe does not exist.
- This is a tooling naming mismatch, not a source-code change.

## Phase-02 Validation Plan
- `python3 -m json.tool docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json >/tmp/amb-green-reset-docs-path.json` -> GREEN
- `python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-green-reset-build-path.json` -> GREEN
- `python3 scripts/ambitions_validate_prompt_headers.py` -> GREEN
- `python3 scripts/ambitions_validate_batch_ids.py` -> GREEN
- `python3 scripts/ambitions-codex-os-validate.py` -> GREEN
- `git diff --check` -> GREEN
- `git status --short` -> shows the owned docs/report changes; the validator-generated report side effect is restored after validation

## Report Location Note
- The batch JSON is stored at the prompt-required path `build/reports/amb-repo-green-flagship-reset-master-01.json`.
- A supporting audit copy is also stored at `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json`.
- The surface vocabulary ledger is deferred, so the JSON does not claim measured zero remaining hits for Train 0.
- `scripts/ambitions-codex-os-validate.py` already allowlists the prompt-required build-report path.
- `build/reports/ambitions-codex-os-validate.json` is a validator-generated side effect and is not a batch-owned output for this train.

## Phase-04 Repair Validation
- `python3 -m json.tool docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01.json >/tmp/amb-green-reset-docs-path.json` -> GREEN
- `python3 -m json.tool build/reports/amb-repo-green-flagship-reset-master-01.json >/tmp/amb-green-reset-build-path.json` -> GREEN
- `python3 scripts/ambitions_validate_prompt_headers.py` -> GREEN
- `python3 scripts/ambitions_validate_batch_ids.py` -> GREEN
- `python3 scripts/ambitions-codex-os-validate.py` -> GREEN
- `git diff --check` -> GREEN
- `git status --short` -> shows the owned batch report/docs; `build/reports/ambitions-codex-os-validate.json` was restored as a generated side effect outside batch ownership.

## Proof Boundary
- This phase only proves that the audit scaffold can be created and parsed.
- It does not prove build, test, accessibility, performance, privacy, or release readiness.
