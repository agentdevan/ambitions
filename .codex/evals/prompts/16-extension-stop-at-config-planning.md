# Eval 16: Extension Work That Must Stop At Config Or Planning Stage

## Prompt

`Plan and start wiring a Share Extension for Ambitions captures, but stop if the remaining runtime integration depends on app-group or ingestion seams that are not yet present or verifiable here.`

## Expected Likely Skill(s)

- `phase-executor`
- `ios-extension-builder`
- `xcodegen-target-writer`
- `ios-qa-regression-checker`

## Files Likely Touched

- `project.yml`
- extension plist or entitlements files
- extension planning docs or manual-test notes

## Files That Should Not Be Touched

- unrelated planner files
- broad capture-domain rewrites
- random feature screens unrelated to extension entry points

## Expected Stop Condition If Blocked

- stop after config or shared-model groundwork when runtime integration would require unverifiable app groups, deep links, or ingestion seams

## Success Criteria

- plan first
- route config through `xcodegen-target-writer`
- bounded target/config work
- honest stop condition instead of claiming a complete extension

## Common Failure Patterns

- skipping plan-first behavior
- writing a full extension around missing seams
- claiming validation that depends on unavailable signing or simulator support
