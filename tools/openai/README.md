# OpenAI Build Suite

This folder contains local, offline-first tooling for Codex/build-control workflows.

## Components

- `config/`: policy and redaction settings.
- `repo_brain/`: local manifest generation + local query utility.
- `evals/`: JSONL datasets and local dry-run eval validator.
- `prompt_repair/`: batch prompt consistency helpers.
- `batch_report/`: closeout report parsing and classification.
- `visual_critique/`: local screenshot/rubric validation helpers.
- `launch_docs/`: launch packet draft generator from audits.

No app runtime dependencies are introduced by this suite.
