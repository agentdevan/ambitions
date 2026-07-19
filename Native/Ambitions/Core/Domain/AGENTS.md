# Domain Layer Guidance

- Keep planning, rescheduling, and goal-engine behavior deterministic.
- Preserve compatibility with current persisted contracts where possible; check persistence and downstream feature usage before changing domain models casually.
- Changes to action flows, Today decisions, feedback handling, or rescheduling require tests.
- Avoid casual rewrites of planner or goal-engine structure when a narrower rule change will do.
- Any domain or persistence-model edit must start with a plan before code changes.
- Apply planner and persistence edits in the smallest deterministic slice possible, then re-check invariants before continuing.
- If a domain change fails validation or exposes an unclear downstream seam, retry only with a narrower grounded fix; otherwise stop and report the risk.
