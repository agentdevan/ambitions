# Codex Improvement Loop

Use this folder after a Codex run was weak, blocked, over-broad, misrouted, under-validated, or inconsistent.

This is a file-based refinement loop, not automatic learning:

1. capture the run using `run-review-template.md`
2. classify the failure using `failure-taxonomy.md`
3. decide the right update layer using `refinement-hierarchy.md`
4. make the smallest system fix using `refinement-playbook.md`
5. add or refine an eval when the failure pattern should not recur silently

Completed runs improve future runs only when the review leads to a durable file update in `.codex/`, not because Codex remembers the run automatically.

## When To Use It

- wrong skill routing
- planning skipped on risky work
- over-editing or scope creep
- invented repo seam
- weak stop condition
- fake or weak validation
- poor retry behavior
- docs truth drift
- XcodeGen or extension wiring mistakes
- planner/domain safety violations
- unclear task intake
- inconsistent final reporting

## Maintenance Rules

- review this layer after any clearly weak or blocked production run
- add a new eval when the failure pattern was not already pressure-tested
- prune or merge overlapping templates when two documents are solving the same problem
- update examples when Ambitions architecture or release flow changes

Use `.codex/templates/post-run-review.md` and `.codex/templates/system-refinement-decision.md` for reusable review output.
