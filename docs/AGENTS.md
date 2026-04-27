# Docs Guidance

- Follow `docs/codex/CONTEXT_INDEX.md` for precedence before editing docs.
- The canonical planning docs live under `docs/canon/` and outrank older roadmap, backlog, audit, release, and implementation notes when conflicts appear.
- `docs/codex/BATCH_REGISTRY.md` is the active queue only; it does not override the active Ambitions 2.0 canon listed in `docs/canon/README.md`.
- Docs must reflect actual shipped repo truth, not historical architecture or planned features.
- Clearly label historical or reference-only material when it is retained for context.
- Do not leave stale references to removed runtime paths or deleted files in active docs.
- Prefer current native source files, `project.yml`, and the validation docs over older roadmap language when updating claims.
- Multi-file docs truth reconciliation should begin with a brief plan so active and historical docs stay consistent together.
- Clean docs in bounded groups and re-check each claim against source before moving to the next file set.
- If repo truth is still uncertain after inspection, stop and report the ambiguity instead of normalizing a guessed claim.
