# Execution Modes

## Available Modes

- `plan-only`: clarify scope, files, validation, and commit plan without editing
- `plan-plus-implement`: risky or multi-layer work that should plan first, then execute
- `implement-bounded-slice`: narrow implementation after the plan or seam is already clear
- `validate-only`: run or document validation for an existing diff
- `review-hardening`: check docs truth, config, release readiness, and remaining risk
- `docs-reconciliation`: correct stale docs and copy against current repo truth
- `blocked-investigation`: inspect, identify the truthful stop point, and report what remains blocked

## Mode Selection Rules

- prefer `plan-plus-implement` for risky native work
- prefer `implement-bounded-slice` only when the seam is already clear
- prefer `blocked-investigation` when the main question is what is actually safe to do

## Profile Interaction

- profiles tune defaults and reasoning intensity
- skills, AGENTS, templates, and operations docs still decide the workflow
- if the active profile is too light for the task, switch the workflow first and the profile second
