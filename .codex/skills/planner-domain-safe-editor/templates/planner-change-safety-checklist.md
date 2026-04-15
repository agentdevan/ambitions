# Planner Change Safety Checklist

- Identify the current domain contract and invariants first.
- Trace downstream consumers in Today, Goals, Goal Detail, and previews.
- Keep behavior deterministic and test-backed.
- Preserve support-mode, untimed, and clarification semantics unless intentionally changed.
- Update tests that exercise the modified rule.
- Note any remaining downstream risk explicitly.
