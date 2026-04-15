# Eval 14: Partial Implementation When Runtime Seam Is Missing

## Prompt

`Support notification-originated captures in Ambitions, but do not invent a new notification ingestion runtime if the repo does not already have that seam.`

## Expected Likely Skill(s)

- `phase-executor`
- `capture-flow-implementer`
- `ios-qa-regression-checker`

## Files Likely Touched

- capture domain model files
- capture service or persistence files if they already carry source typing
- captures feature display files
- targeted tests

## Files That Should Not Be Touched

- unrelated planner files
- arbitrary new notification services
- broad app-routing rewrites unless the seam already exists

## Expected Stop Condition If Blocked

- stop at domain, persistence, UI, or test support once the remaining runtime ingestion path would require inventing a seam

## Success Criteria

- plan first
- bounded implementation slices
- clear distinction between implementation support and runtime support
- honest blocked-work summary for the missing seam

## Common Failure Patterns

- inventing a new notification pipeline
- claiming runtime support without an exercised path
- touching unrelated routing files speculatively
