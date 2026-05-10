# AUTO-HARDEN-01 Hardening Audit

## Scope
- Approved file boundary-only updates to runner/prompt governance assets.
- No app-source files modified.

## Hardening outcome
- Enforced strict required runner metadata checks in `scripts/ambitions-wrap-prompt.sh`.
- Tightened runnable prompt classification in `scripts/ambitions-prompt-audit.sh` to require:
  - complete runner header metadata (required markers present and exact), and
  - explicit batch-prompt shape (`Batch ID`/`make batch` signal).
- Added self-check assertions in `scripts/ambitions-runner-self-check.sh` for:
  - explicit runner defaults and branch-exception defaults,
  - required metadata markers in `_RUNNER_REQUIRED_HEADER.md` and `_BATCH_TEMPLATE.md`,
  - canonical IA copy in template and hybrid-runner docs.
- Updated `docs/codex/ambitions-hybrid-runner.md` with required-runner-metadata guidance.

## Validation
Executed from `/Users/devan/Documents/GitHub/ambitions`.

- `git diff --check` — `exit 0`
- `bash -n scripts/ambitions-codex-train.sh` — `exit 0`
- `bash -n scripts/ambitions-wrap-prompt.sh` — `exit 0`
- `bash -n scripts/ambitions-prompt-audit.sh` — `exit 0`
- `bash -n scripts/ambitions-runner-self-check.sh` — `exit 0`
- `test -x scripts/ambitions-codex-train.sh` — `exit 0`
- `test -x scripts/ambitions-wrap-prompt.sh` — `exit 0`
- `test -x scripts/ambitions-prompt-audit.sh` — `exit 0`
- `test -x scripts/ambitions-runner-self-check.sh` — `exit 0`
- `make -n batch BATCH=TEST PROMPT=prompts/_BATCH_TEMPLATE.md` — `exit 0`
- `make -n prompt-audit` — `exit 0`
- `make -n batch-status` — `exit 0`
- `scripts/ambitions-codex-train.sh --self-check` — `exit 0`
- `scripts/ambitions-prompt-audit.sh` — `exit 0`

The audit command reported:
- `YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata`
- `Active runnable prompts audited: 2`
- `Support/eval/template/historical files classified: 775`
