# Structured Codex OS Output

Use this schema for machine-readable batch result reports when available.

- Schema path: `.codex/schemas/ambitions-batch-result.schema.json`
- Intended command: `codex exec --json --output-schema .codex/schemas/ambitions-batch-result.schema.json`
- Report fields are local-only and require no API keys, remote calls, or paid services.
- Validate locally with `python3 scripts/ambitions-codex-os-validate.py`.

Use schema validation as a runner preference, not an API dependency.

Current batch behavior:

- Optional runner inputs:
  - `STRUCTURED_OUTPUT=1|0`
  - `OUTPUT_SCHEMA=.codex/schemas/ambitions-batch-result.schema.json`
  - `OUTPUT_REPORT_DIR=build/reports/codex-runs`
- If enabled, the runner writes a local structured JSON summary and keeps defaults unchanged when disabled.
- If direct `codex exec --output-schema` support is unavailable or ambiguous, local JSON generation remains the supported path.
