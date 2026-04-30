# Release Claim Discipline Protocol

## When To Use

Use this protocol for release claim discipline protocol work in Ambitions 3.0.

## Required Inputs

- Current `git status --short`.
- Ambitions 3.0 required read order.
- Target context pack and skill.
- Known FAANG handoff risks when relevant.

## Exact Steps

1. Confirm branch and local state.
2. Read the Ambitions 3.0 source hierarchy.
3. Select the smallest context pack, skill, and validation pack.
4. Name touch budget before edits.
5. Execute only the requested scope.
6. Run focused validation.
7. Document PASS/PARTIAL/FAIL and next prompt.

## Commands

```bash
git status --short
git branch --show-current
git rev-parse HEAD
rg -n --hidden --glob '!/.git/**' 'Ambitions_2_0|Batch 61|Master Product and Visual System Spec v2 is now the active' AGENTS.md README.md docs/README.md docs/codex docs/canon/Ambitions_3_0_* docs/canon/README.md || true
```

## Output Artifacts

- Updated code/docs where in scope.
- Audit or report file when the protocol is audit-facing.
- Validation evidence in final report.

## Stop Conditions

- Missing credentials/tooling block the requested action.
- Source truth conflict cannot be resolved from files.
- The next action would require broad product implementation outside scope.
