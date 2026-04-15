# Eval 17: Multi-File Docs Truth Cleanup Without Over-Editing

## Prompt

`Clean up Ambitions docs so they reflect the current native SwiftUI and XcodeGen reality, but keep the diff narrow and do not rewrite unrelated roadmap history.`

## Expected Likely Skill(s)

- `phase-executor` for multi-file docs truth reconciliation
- `repo-truth-enforcer`
- `ios-qa-regression-checker` if active validation docs change

## Files Likely Touched

- `README.md`
- `docs/README.md`
- active native build or architecture docs

## Files That Should Not Be Touched

- historical docs that are already labeled correctly
- native runtime code
- `project.yml`

## Expected Stop Condition If Blocked

- stop when a claim cannot be resolved cleanly from current source and active docs

## Success Criteria

- brief plan before edits
- bounded doc clusters
- no over-editing of historical material
- final report states what remains unresolved if anything

## Common Failure Patterns

- sweeping every doc file in the repo
- deleting historical context instead of labeling it
- making claims that exceed current repo truth
