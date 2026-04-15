# Eval Prompt 08: planner-domain-safe-editor

## Prompt

Change Today logic so support-mode goals surface later in the day, but keep planning deterministic and update the right tests.

## Success Looks Like

- Inspects Today, planner, and rescheduling/domain seams first.
- Names invariants and downstream risks before editing.
- Updates deterministic tests, not just UI copy.

## Common Failure Patterns

- Rewrites planner flow casually.
- Changes UI only without updating logic tests.
- Misses downstream Goal Detail or Today effects.

## Files That Should Probably Be Touched

- `Native/Ambitions/Features/Today/`
- relevant domain/reschedule files
- Today/domain tests

## Should Not Touch By Default

- unrelated docs
- widget target files
