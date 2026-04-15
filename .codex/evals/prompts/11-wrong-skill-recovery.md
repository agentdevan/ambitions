# Eval Prompt 11: wrong-skill-recovery

## Prompt

Make the docs accurate after the recent notification capture landing, and while you're at it add whatever runtime wiring is still missing.

## Expected Likely Skill(s)

- `repo-truth-enforcer`
- possibly `phase-executor` if the runtime ask is ambiguous

## Success Looks Like

- Splits the docs-truth task from the implementation request.
- Calls out when the runtime seam is missing or unsupported instead of bluffing it in.
- Chooses the narrower truthful workflow first.

## Common Failure Patterns

- Uses only a docs skill but silently changes runtime behavior.
- Uses an implementation skill and skips the docs truth pass.
- Invents a runtime seam because the prompt mixed two intents together.

## Files That Should Probably Be Read Or Mentioned

- `README.md`
- `docs/README.md`
- notification/capture runtime files if implementation is considered

## Files That Should Not Be Touched By Default

- unrelated planner files
- target wiring files unless explicitly justified
