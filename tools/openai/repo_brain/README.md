# OpenAI Repo Brain (Local)

This layer provides a deterministic local index and query path for tool-assisted repo work.

## Files

- `build_repo_manifest.py`: builds a local JSON manifest for allowed docs/tooling paths.
- `query_repo_brain.py`: local query helper explaining future file-search/vector integration.

## Allowed index inputs

- `docs/truth/**`
- `docs/codex/**`
- `docs/audits/**`
- `prompts/batches/**`
- `scripts/**`

## Non-goals

- No live OpenAI API calls in this batch.
- No user data export by default.
- No runtime dependency added to app targets.
