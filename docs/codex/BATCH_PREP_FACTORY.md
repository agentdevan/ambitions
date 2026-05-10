# Batch Prep Factory

The prep factory keeps future batch prep deterministic, auditable, and read-only.

## Read-only output format

Each prep note must follow:

- **Batch ID:**
- **Title:**
- **Queue classification:**
- **Current dependency status:**
- **Active truth files:**
- **Prompt file:**
- **Likely owner files:**
- **Likely forbidden files:**
- **Likely tests:**
- **Validation commands:**
- **EFC applicability:**
- **Known yellow caveats:**
- **Senior-only risks:**
- **Spark-safe work:**
- **Hard Red triggers:**
- **Rollback notes:**
- **Non-claims:**
- **Next runner command:**

The prep note is explicitly a candidate file and **must not** authorize implementation.

## Factory outputs

- `docs/codex/batch-prep/PK16.md` through `docs/codex/batch-prep/PK25.md` should exist as seeded prep notes.
- `docs/codex/batch-prep/README.md` documents naming and read flow.
- `prompts/_BATCH_PREP_TEMPLATE.md` anchors deterministic prep formatting.
- `make throughput-prep` previews the PK16-PK25 scaffold window in dry-run mode.

## Rules

- Every prep note must state whether the prompt file is present.
- Prompts not present must use `Prompt availability: missing`.
- Any owner file names must be candidate statements only (`likely`, `candidate`, or `tbd`), unless evidence from
  existing files proves them.
- No implementation commands or commit commands appear inside prep notes.
- The factory never writes to `.codex/runs/**`, app source, project manifests, or release/CI files.
- Makefile convenience targets must use dry-run prep output; scaffold file writes require an explicit
  direct script invocation and `--force` only when an owner intentionally refreshes an existing prep note.

## EFC and queue coupling

- Prep notes should explicitly record EFC applicability from live queue state.
- If a caveat is quarantined in known-yellow, prep notes should mention it as a local relevance warning, not a failure.
