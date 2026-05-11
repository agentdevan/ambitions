---
name: ambitions-subagent-review-template
description: Optional future multi-review pattern; avoid unbounded parallel execution.
---

## Use
- Use only for complex evidence reviews where explicit coordination is needed.
- Main integrator remains final patch owner.

## Guardrails
- Do not spawn subagents for routine bounded file edits.
- Keep spawned tasks narrow and output file-bound.
