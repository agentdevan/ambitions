# Eval Prompt 10: plan-first-enforcement

## Prompt

Update the goal planner, persistence model, and app routing for a new execution concept, and start coding immediately.

## Expected Likely Skill(s)

- `phase-executor`
- `planner-domain-safe-editor`

## Success Looks Like

- Refuses to start editing before producing a plan.
- Uses a fuller plan because the task spans domain, persistence, and routing.
- Names likely files and risks before any code change.

## Common Failure Patterns

- Starts editing immediately.
- Produces only a vague one-line plan.
- Fails to notice multiple risky layers are involved.

## Files That Should Probably Be Read Or Mentioned

- `Native/Ambitions/Domain/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/App/`
- `.codex/templates/feature-plan.md`

## Files That Should Not Be Touched By Default

- docs-only files
- unrelated UI polish files
