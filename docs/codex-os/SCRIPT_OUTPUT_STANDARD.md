# Script Output Standard

Status: Active Codex OS v2 standard
Authority: Process standard, subordinate to current raw logs and `docs/truth/*`

## What It Is

Script output is the full local evidence stream for deterministic program scripts.

## What It Is Not

Generated logs are not proof unless scoped, indexed, and tied to a claim. Logs do not prove app build, tests, accessibility, performance, device validation, privacy/legal approval, or release readiness unless the command itself proves that scope.

## Required Behavior

- Full output saved to `artifacts/<program>/script-output/`.
- Summaries include command, exit code, pass/fail, top findings, and artifact path.
- Avoid pasting massive `rg` logs into Linear.
- Logs must not contain secrets, API keys, private personal data, or source-pack payloads.
- Logs should include program, phase/issue when relevant, branch, commit, date, and command.

## Program Roots

- UIQL: `artifacts/ui-quality-lockdown/script-output/`
- PLOS: `artifacts/plos-runtime/script-output/`
- SAF/source-atlas: `artifacts/source-atlas-factory/script-output/`
- CODEX-OS: `artifacts/codex-os-v2/script-output/`

## Green / Yellow / Red

Green: log exists, exit recorded, summary concise, proof ledger references it when used for a claim.
Yellow: advisory command, timeout, or external access limit is explicit.
Red: missing log for claimed validation, secret in output, hidden failed command, or forbidden mutation.

## Repair / Rollback / Linear

Keep full logs and summarize. Clean secret-bearing artifacts before commit. Move/regenerate logs filed under the wrong program. Linear updates cite path and summary only.
