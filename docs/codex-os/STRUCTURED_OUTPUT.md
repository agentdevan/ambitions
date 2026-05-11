# Structured Codex OS Output

Use this schema for machine-readable batch result reports when available.

- Schema path: `.codex/schemas/ambitions-batch-result.schema.json`
- Intended command: `codex exec --json --output-schema .codex/schemas/ambitions-batch-result.schema.json`
- Report fields are local-only and require no API keys, remote calls, or paid services.
- Validate locally with `python3 scripts/ambitions-codex-os-validate.py`.

Use schema validation as a runner preference, not an API dependency. If a caller cannot use schema mode, provide the same fields in equivalent human-readable markdown and keep manual validation evidence attached.
