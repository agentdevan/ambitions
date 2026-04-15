# Failure Taxonomy

## Routing And Workflow

- `wrong-skill-routing`: the task should have used a different primary skill
- `missing-skill-chain`: the primary skill was right but a follow-on skill should have been used
- `planning-skipped`: risky work started without a plan
- `wrong-execution-mode`: plan-only, validate-only, or bounded-slice mode should have been chosen differently

## Scope And Safety

- `over-editing`: the diff crossed unrelated repo areas
- `seam-invention`: the run implied a runtime, routing, or extension seam that the repo does not actually have
- `weak-stop-condition`: the run kept pushing after a truthful stop point
- `poor-retry-behavior`: the same failing action repeated without a narrower next move
- `domain-safety-violation`: planner, Today, or persistence logic changed too casually

## Validation And Truth

- `weak-validation`: the run blurred verified and unverified checks
- `fake-validation`: build, test, or runtime claims were made without being run
- `docs-truth-drift`: docs, previews, or copy no longer match the repo
- `release-hardening-gap`: a merge or release readiness check missed config, docs, or validation work

## Intake And Reporting

- `unclear-task-intake`: the request was underspecified for safe execution
- `reporting-inconsistency`: the final report was not structured enough to trust what happened
- `review-gap`: the post-run review did not identify the right root cause or update layer

## Suggested Primary Fix Layer

- AGENTS: durable repo-wide or local code-area rule
- Skill: repeatable workflow or routing mistake
- Template: output, review, or planning structure problem
- Eval: untested failure pattern
- Config docs: misunderstood profile or config usage
- Operations docs: intake, execution mode, escalation, validation, or release flow confusion
