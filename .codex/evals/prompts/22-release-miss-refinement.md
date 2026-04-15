# Eval 22: Release-Hardening Miss Should Update The System

## Prompt

`Do a merge-readiness pass for an Ambitions branch with docs changes, plist edits, and extension wiring, then tell me what checklist, eval, or operations doc should change if the pass misses a release blocker.`

## Expected Likely Skill(s)

- `release-hardening`
- `repo-truth-enforcer`
- `ios-qa-regression-checker`
- post-run review templates

## Files Likely Touched

- release templates
- release-flow docs
- release evals

## Files That Should Not Be Touched

- unrelated planner files
- arbitrary new features

## Expected Stop Condition If Blocked

- stop short of a release-ready claim when validation or config truth is incomplete

## Success Criteria

- release/readiness flow is explicit
- the refinement path is clear if a blocker was missed

## Common Failure Patterns

- using release-hardening without docs truth or QA follow-on
- no durable system update after the miss
