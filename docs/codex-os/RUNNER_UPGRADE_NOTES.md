# Runner upgrade notes

Batch `AMB-CODEX-OS-NO-COST-HARDENING-002` added a no-cost, opt-in local structured summary path:

- Added `STRUCTURED_OUTPUT=1|0` support to `scripts/ambitions-codex-train.sh`.
- Added optional `OUTPUT_SCHEMA` and `OUTPUT_REPORT_DIR` inputs with backward-compatible defaults.
- Kept default behavior unchanged when `STRUCTURED_OUTPUT` is unset or `0`.
- Runner summary writes local JSON under `OUTPUT_REPORT_DIR` only when opt-in is enabled.
- No CLI `--output-schema` enforcement was added; structured output remains local and schema compliant.
