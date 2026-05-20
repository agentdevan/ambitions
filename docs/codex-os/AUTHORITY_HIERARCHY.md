# Ambitions Codex OS Authority Hierarchy

## Active source truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `docs/AGENTS.md`
- `scripts/AGENTS.md`
- `.codex/AGENTS.md`
- `.agents/AGENTS.md`
- `docs/codex-os/`

## Supporting implementation material

- `.codex/config.toml`
- `.codex/rules/ambitions-no-cost.rules`
- `.codex/hooks/*.py`
- `.codex/schemas/ambitions-batch-result.schema.json`
- `scripts/ambitions-codex-os-validate.py`
- `scripts/ambitions-codex-os-doctor.py`
- `Makefile` targets for Codex OS validation/doctor
- `.agents/skills/` files
- `prompts/` runner-compatible prompt artifacts that remain pending, historical, or supporting execution references only

## Historical reference

- Previous prompt files and batch documentation that remain for continuity.
- Legacy governance text in older batch logs and run directories.
- Root prompt installers, `prompts/batches/`, `prompts/ambitions/`, `prompts/moat-install/`, `prompts/generated/`, and related runner-compatible prompt artifacts are historical or supporting unless a current runner-selected batch refreshes them.

## Obsolete / archive-candidate

- If duplicate runner-hardening notes emerge in other locations, classify in PR/closeout updates and migrate references to `docs/codex-os`.
- Old unindexed control notes without schema or hook references are candidates for archival cleanup.

## Delete-candidate

- No files in this batch are marked delete-candidate.
- Avoid deleting historical evidence until compatibility review and active queue alignment are complete.
