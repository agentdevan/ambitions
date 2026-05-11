# Runner upgrade notes

Runner integration was reviewed but left unchanged in this batch for safety.

Recommended minimal safe upgrade (future batch):

1. Preserve existing `scripts/ambitions-codex-train.sh` behavior.
2. Add optional `--output-schema` and `--report-dir` support.
3. Keep default command execution paths unchanged.
4. Avoid API-key, CI, or signing paths.
5. Validate with local smoke run and keep fallback to current non-schema mode.

Do not patch now unless command-shape and backward compatibility tests are explicit and green.
