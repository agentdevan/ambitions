# Ambitions 3.0 Prompt Quality Rubric

Status: Active Codex intake rubric

Score each prompt from 0 to 2 for every criterion:

| Criterion | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Source truth included | Missing | Mentions docs loosely | Names 3.0 docs/read order |
| Task width defined | Missing | Implied | XS/S/M/L/XL/XXL stated |
| Primitive named | Missing | Broad area only | Specific primitive/surface |
| Allowed files named | Missing | Broad directories | Clear touch budget |
| Forbidden files named | Missing | Partial | Clear no-touch areas |
| Validation named | Missing | Generic tests | Specific validation pack/commands |
| Stop conditions named | Missing | Generic blockers | Concrete stop/escalation rules |
| Output format clear | Missing | Partial | Exact closeout/report shape |
| Release claims controlled | Missing | Generic caution | Explicit claim-state constraints |
| No broad fix-everything language | Broad | Some scope risk | Bounded and split-ready |

## Interpretation

- 18-20: Ready for Codex execution.
- 14-17: Acceptable for S/M work with Codex clarification from files.
- 10-13: Needs narrowing before risky edits.
- Under 10: Split or rewrite before execution.

Prompts asking Codex to fix everything, modernize all tests, migrate all identifiers, redesign all surfaces, or claim readiness without gates should be rejected or split.
