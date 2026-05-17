<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01

## Objective

Add a safe read-only audit mode or clearly documented operator path for Ambitions runner-mediated audits that must not create branches, commits, pushes, or mutable `.codex/runs` artifacts unexpectedly.

This is Codex OS/tooling only. Do not modify app source or product behavior.

## Active Source Truth To Inspect

- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-runner-self-check.sh`
- `scripts/ambitions-prompt-audit.sh`
- `Makefile`
- `.codex/README.md`
- docs/codex runner docs if present

## Allowed Scope

- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-runner-self-check.sh`
- `scripts/ambitions-prompt-audit.sh`
- `Makefile`
- `.codex/README.md`
- `docs/codex/**` runner/operator docs
- focused tests/self-check fixtures for runner behavior

## Required Work

- Provide a deterministic way to run audit/report-only batches without branch creation, commit creation, push, or surprise tracked source mutation.
- Ensure self-check or a focused dry-run check proves the read-only audit posture.
- Keep default safety conservative and backwards-compatible.

## Validation Expectations

- `scripts/ambitions-codex-train.sh --self-check`
- `scripts/ambitions-prompt-audit.sh`
- `bash -n scripts/ambitions-codex-train.sh`
- `git diff --check`

## Forbidden Scope

- No app source changes.
- No git mutation during validation.
- No hosted CI, provider, network, shell-MCP, or secret-reading tooling.

## Runner Command

```bash
make batch BATCH=CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01 PROMPT=prompts/batches/CODEX-RUNNER-READ-ONLY-AUDIT-MODE-01.md
```
