# Markdown Doc QA Runner

## Purpose

Run Ambitions 3.0 documentation QA without turning known documentation backlog or flaky external links into accidental product-blocking gates.

## Use When

- A task changes Markdown, Codex prompts, canon docs, reports, indexes, or `.codex/` operating material.
- A closeout needs stale-guidance, deprecated-language, Markdown lint, or link-check evidence.
- A docs QA workflow is being compared between local Mac and GitHub Actions.

## Do Not Use When

- The task is product-code-only and no docs or public claims changed.
- The user explicitly asks not to run documentation scans.
- Missing optional tools would distract from a higher-priority build/test failure.

## Required Docs To Read

- `docs/canon/Ambitions_3_0_Dependency_Management_Policy.md`
- `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`
- `.codex/validation/doc-qa-pack.md`
- `.codex/operations/local-validation-protocol.md`

## Primary Files Likely Touched

- Markdown docs under `README.md`, `docs/`, and `.codex/`
- `scripts/run-doc-qa.sh`
- `Brewfile`
- Future docs QA workflow files only after credentials include `workflow` scope.

## Required Plan Shape

Name the docs touched, whether QA is advisory or strict, which logs were produced, and which findings are historical/supporting versus active guidance defects.

## Implementation Rules

- Use `scripts/run-doc-qa.sh` for local scans.
- Use `DOC_QA_STRICT=1 scripts/run-doc-qa.sh` only when the task explicitly promotes docs QA to a blocking gate.
- Keep generated logs ignored.
- Do not rewrite product strategy just to silence a lint or link finding.

## Validation Commands

```bash
scripts/run-doc-qa.sh || true
DOC_QA_STRICT=1 scripts/run-doc-qa.sh || true
```

## Evidence Output

Report stale-guidance status, deprecated-language status, Markdown lint status, lychee status, log directory, strictness, and whether any finding blocks the current task.

## Common Failure Modes

- External links fail due to network or rate limits.
- Markdown lint surfaces old docs backlog unrelated to the touched files.
- Deprecated-language scan finds intentional historical examples.

## Stop Conditions

- Active docs instruct Codex to start from stale 2.0/v2 sources.
- Strict docs QA blocks and the task did not authorize broad docs cleanup.
- Link checker failures require network/account access that is unavailable.

## Related Skills

- `dependency-auditor.md`
- `legacy-language-sweeper.md`
- `active-canon-linker.md`
- `stale-doc-reconciler.md`
