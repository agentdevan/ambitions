# Domain Layer Guidance

- Keep planning, rescheduling, and goal-engine behavior deterministic.
- Preserve compatibility with current persisted contracts where possible; check persistence and downstream feature usage before changing domain models casually.
- Changes to action flows, Today decisions, feedback handling, or rescheduling require tests.
- Avoid casual rewrites of planner or goal-engine structure when a narrower rule change will do.
