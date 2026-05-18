# AMB-CHATGPT-TO-CODEX-PROMPT-STANDARD

Status: supporting prompt standard

This standard defines how ChatGPT should write prompts for Codex in the
Ambitions repo.

## Required header

Every prompt must begin with:

```md
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

## Required prompt sections

- Batch ID
- Type
- Objective
- Active source truth to inspect first
- Allowed scope
- Forbidden scope
- Validation expectations
- Proof and claim boundaries
- Rollback notes
- Next command or handoff

## Required behavior

- Inspect `docs/truth/*` before patching.
- Use Ambitions nouns and product terms instead of generic productivity terms.
- Keep each prompt bounded to one repair or one implementation slice.
- State what must not change as clearly as what may change.
- Require exact commands and exact evidence for claims.

## Mode labels

Use one of these labels explicitly when the prompt asks for a mode:

- installer
- audit
- repair
- implementation
- review
- release gate
- visual QA
- privacy audit
- continuity proof
