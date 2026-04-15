# Refinement Hierarchy

When a failure happens, update the narrowest layer that would have prevented it.

## Update Root `AGENTS.md` When

- the rule should apply to nearly all Ambitions work
- the failure was about repo-wide truth, planning, retries, validation honesty, or broad scope control

## Update Nested `AGENTS.md` When

- the rule belongs only to App, Domain, Features, or Docs
- the failure was local to routing, planner invariants, feature boundaries, or docs truth handling

## Update A Skill When

- the problem was in a repeatable workflow
- better metadata, chaining, failure recovery, or validation instructions would improve future runs

## Update A Template When

- Codex knew what to do but reported or structured it poorly
- the plan, review, blocked-work, or final summary shape was too weak or inconsistent

## Update An Eval When

- the failure pattern was not being pressure-tested
- a skill or workflow changed and needs a regression check

## Update Config Docs When

- the problem came from profile misunderstanding, trusted-project behavior, or config expectations
- do not treat config as the fix for instruction or workflow mistakes

## Update Operations Docs When

- the task intake was unclear
- the wrong task class or execution mode was chosen
- escalation, validation, or release flow expectations were unclear
