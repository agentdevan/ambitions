# Supersession Retirement Plan

Status: Bootstrap Yellow.

No Swift source is deleted in this batch. Retirement requires a future cleanup batch after:

- canonical champion is identified
- useful behavior is extracted or explicitly declined
- tests/proof cover rescued behavior
- references are updated
- rollback path exists
- owner approval is recorded

| Path | Superseded by | Useful content to extract | Tests needed before retirement | Risk level | Suggested action | Required owner approval | Rollback path |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/Features/Plan` | time_root | Compatibility planning behavior, if still useful | Time compatibility tests | High | keep active compatibility pending review | yes | revert future cleanup batch only |
