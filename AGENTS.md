# Ambitions Codex Guidance

- `Native/Ambitions/` is the source of truth for the shipping app. Treat older Expo/TypeScript material as reference-only unless a task explicitly targets it.
- Use XcodeGen. Edit `project.yml` and regenerate the project instead of relying on a checked-in `.xcodeproj`.
- Preserve architecture boundaries: app and routing in `Native/Ambitions/App`, domain logic in `Native/Ambitions/Domain`, services in `Native/Ambitions/Services`, persistence in `Native/Ambitions/Persistence`, feature UI in `Native/Ambitions/Features`, shared UI in `Sources/` and `AppUI/Sources/`.
- Avoid broad rewrites when targeted edits are sufficient. Extend current repo patterns instead of introducing parallel abstractions.
- Plan first for risky changes involving domain logic, XcodeGen, extensions, persistence, or app routing.
- After meaningful changes, run the relevant generation, build, and test workflow when the environment supports it.
- Do not claim validation that was not run.
- Keep docs, copy, previews, and shipped behavior truthful to the current repo state.
- Use repo-local skills in `.codex/skills/` for specialized recurring workflows instead of expanding this file with task-specific procedures.
