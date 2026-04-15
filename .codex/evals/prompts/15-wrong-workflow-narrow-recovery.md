# Eval 15: Wrong First Workflow Then Narrow Recovery

## Prompt

`Make the stale docs truthful after the last native cleanup, but if you realize this is not a feature implementation task, recover to the right workflow instead of editing code.`

## Expected Likely Skill(s)

- `repo-truth-enforcer`
- `ios-qa-regression-checker`

## Files Likely Touched

- `README.md`
- `docs/`
- preview or copy files only if they contain stale claims

## Files That Should Not Be Touched

- native feature implementation files
- planner logic
- `project.yml`

## Expected Stop Condition If Blocked

- stop on unresolved claim ambiguity after re-checking current source and docs

## Success Criteria

- explicit recovery from the wrong workflow if feature implementation was the initial instinct
- bounded doc groups
- no opportunistic code edits
- truthful final report

## Common Failure Patterns

- leaving stale claims untouched because the task was misclassified
- editing code to make docs true
- sweeping unrelated doc rewrites
