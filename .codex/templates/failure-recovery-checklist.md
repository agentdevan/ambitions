# Failure Recovery Checklist

## Trigger

- Wrong skill likely selected
- Multiple skills overlap
- No skill fits cleanly
- Risky task started without a plan
- Validation cannot run here
- Repo truth is uncertain
- Requested feature would require inventing a seam that does not exist

## Recovery Steps

1. State the failure mode explicitly.
2. Switch to the narrowest correct skill or plan workflow.
3. If risky work has no plan yet, stop and write one before editing.
4. If repo truth is uncertain, inspect the source files and active docs again before changing code.
5. If the requested behavior needs a seam the repo does not have, downgrade to a truthful implementation instead of inventing unsupported runtime behavior.
6. Keep the diff narrow and name the areas intentionally left untouched.
7. Use the validation summary template to separate verified, not verified, and manual follow-up.
