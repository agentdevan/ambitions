# AMB-CHATGPT-DECISION-LOG-STANDARD

Status: supporting decision record standard

Use this format when ChatGPT needs to record a repo decision before a Codex
batch is created.

## Required fields

- Date
- Batch or task ID
- Question asked
- Active truth consulted
- Options considered
- Decision
- Why the decision is narrow and safe
- Conflict with older docs, if any
- Follow-up validation required
- Next handoff

## Decision log rule

If the decision changes active canon, architecture, release posture, or scope,
the log must say so explicitly and point to the truth file that governs the
change.

## Example shape

```md
Date:
Batch ID:
Question:
Truth consulted:
Decision:
Reason:
Conflicts:
Validation:
Next handoff:
```
