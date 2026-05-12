# Repo Intelligence Layer

## Purpose

Provide deterministic local context for batch tooling while preserving local-only architecture.

## Manifest

`tools/openai/repo_brain/build_repo_manifest.py` builds a local JSON manifest from:

- `docs/truth/**`
- `docs/codex/**`
- `docs/audits/**`
- `prompts/batches/**`
- `scripts/**`

## Live API policy

No live OpenAI API calls are made in this batch.

## Query path

`tools/openai/repo_brain/query_repo_brain.py` searches the local manifest and prints results.

Planned future path:

1. Build manifest.
2. Upload normalized chunks to a future local/restricted vector store.
3. Run non-production queries.
4. Keep all raw user content out of vector paths unless explicitly approved.
