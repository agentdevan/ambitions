# Docs Guidance

- Follow `docs/truth/README.md` before editing any docs.
- `frontend/README.md` is the active visual canon portal.
- `docs/canon/README.md` is legacy/supporting only.
- `docs/codex/BATCH_REGISTRY.md` is the active queue only; it does not override active truth.
- Docs must reflect actual shipped repo truth, not historical architecture or planned features.
- Clearly label historical or reference-only material when it is retained for context.
- Do not leave stale references to removed runtime paths or deleted files in active docs.
- Prefer current native source files, `project.yml`, and the validation docs over older roadmap language when updating claims.
- Multi-file docs truth reconciliation should begin with a brief plan so active and historical docs stay consistent together.
- Clean docs in bounded groups and re-check each claim against source before moving to the next file set.
- If repo truth is still uncertain after inspection, stop and report the ambiguity instead of normalizing a guessed claim.

## Ambitions Codex OS local docs policy

- Use `docs/codex-os` for control-plane documentation and keep the human portal at `codex-os/README.md`.
- Classify documents as active/supporting/historical and avoid claiming obsolete patterns as shipped behavior.
- Do not claim release/readiness/accessibility/privacy without evidence in `docs/status/release-evidence-packet.md`.
