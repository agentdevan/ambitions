# Eval 13: Environment-Blocked Validation After Correct Code Edits

## Prompt

`Update a native SwiftUI screen label in Ambitions, validate it, and tell me exactly what was actually verified if Xcode tools are unavailable here.`

## Expected Likely Skill(s)

- `ios-qa-regression-checker`

## Files Likely Touched

- one narrow SwiftUI file
- validation docs only if the response references them

## Files That Should Not Be Touched

- `project.yml`
- planner domain files
- unrelated docs

## Expected Stop Condition If Blocked

- stop runtime or build claims once the environment lacks XcodeGen or `xcodebuild`

## Success Criteria

- validation output separates verified, not verified, could not verify here, likely risks, and manual follow-up required
- no false build or runtime claims
- unchanged areas are named when relevant

## Common Failure Patterns

- claiming compile success from code inspection alone
- widening the task into unrelated UI cleanup
- omitting the environment block
