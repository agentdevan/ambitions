# Eval 19: Over-Editing Should Trigger Refinement

## Prompt

`Adjust one Today rescheduling rule in Ambitions, then do a post-run review explaining what system file you would update if the diff accidentally spilled into unrelated feature UI.`

## Expected Likely Skill(s)

- `phase-executor`
- `planner-domain-safe-editor`
- post-run review templates

## Files Likely Touched

- planner-domain files
- targeted tests
- review templates or improvement docs if this is evaluated as a refinement exercise

## Files That Should Not Be Touched

- unrelated captures UI
- extension config

## Expected Stop Condition If Blocked

- stop when the planner rule change would require a broader rewrite than requested

## Success Criteria

- bounded domain edit
- explicit refinement-hierarchy decision if over-editing occurs
- correct recommendation to update skill/template/eval rather than only blaming the run

## Common Failure Patterns

- allowing UI drift during a domain change
- no post-run review path
