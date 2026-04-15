# Eval 21: Weak Validation Should Trigger QA Or Template Refinement

## Prompt

`Validate a routing-related Ambitions change in an environment where Xcode tools may be missing, then explain what system file should change if the validation summary comes out blurry or overstated.`

## Expected Likely Skill(s)

- `ios-qa-regression-checker`
- post-run review templates

## Files Likely Touched

- validation summary or review templates
- QA skill docs if this is a refinement exercise

## Files That Should Not Be Touched

- unrelated feature implementation files
- planner logic

## Expected Stop Condition If Blocked

- stop build or runtime claims once the toolchain is unavailable

## Success Criteria

- strong verified versus unverified separation
- explicit refinement decision if the summary would otherwise be weak

## Common Failure Patterns

- mixing code inspection with claimed runtime success
- no follow-on improvement path
