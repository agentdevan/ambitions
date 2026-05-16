# Prompt Artifacts

Status: Active prompt-routing index  
Authority: Subordinate to `docs/truth/*`, direct user instruction, and current source/proof evidence.

Files under `prompts/` are execution artifacts. They are not active product truth, implementation proof, release proof, or current Codex/direct-execution instructions unless explicitly refreshed and selected for a current run.

## Reading rules

1. Start with `docs/truth/README.md`.
2. Confirm current execution mode from the user and `docs/status/repo-governance-master-cleanup-plan.md`.
3. Treat historical prompt files as references only.
4. Do not run or reuse old prompts without reconciling them against current truth files and current repo status.
5. Do not let prompt files override direct user instruction.

## Classification

- `prompts/batches/`: historical or pending execution artifacts.
- Runner-compatible prompt files are only executable when the user explicitly chooses the runner path.
- Direct GitHub API cleanup trains must not create prompt files as their deliverable.
- Old prompts may be mined for durable decisions only after those decisions are extracted into active truth/status files.

## Hard stops

- Do not treat prompt files as current authority.
- Do not treat prompt files as evidence that code, UI, tests, accessibility, or release readiness exist.
- Do not resurrect old Plan/Profile/Captures/PXOS/ACUI language from prompts without active-truth reconciliation.
- Do not delete prompt files without inbound-reference checks and cleanup-register updates.
