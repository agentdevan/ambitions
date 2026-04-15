# Ambitions Codex Guidance

- `Native/Ambitions/` is the source of truth for the shipping app. Treat older Expo/TypeScript material as reference-only unless a task explicitly targets it.
- Use XcodeGen. Edit `project.yml` and regenerate the project instead of relying on a checked-in `.xcodeproj`.
- Preserve existing architecture boundaries: app/navigation in `Native/Ambitions/App`, feature flows in `Native/Ambitions/Features`, domain logic in `Native/Ambitions/Domain`, services in `Native/Ambitions/Services`, persistence in `Native/Ambitions/Persistence`, shared UI in `Sources/` and `AppUI/Sources/`.
- Prefer deterministic, minimal edits that extend current repo patterns instead of introducing parallel abstractions.
- After meaningful changes, run the relevant generation, build, and test workflow for this repo and report what was or was not validated.
- Keep docs, copy, previews, and shipped behavior truthful to the current repo state.
- Use repo-local skills in `.codex/skills/` for specialized workflows instead of expanding this file with task-specific procedures.
