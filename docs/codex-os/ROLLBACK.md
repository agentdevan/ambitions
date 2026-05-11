# Rollback (Codex OS hardening scope)

Use path-specific rollback for this batch only.

```bash
git checkout -- AGENTS.md docs/AGENTS.md .codex/config.toml Makefile scripts/ambitions-codex-train.sh
git checkout -- scripts/AGENTS.md .codex/AGENTS.md .agents/AGENTS.md prompts/ambitions/README.md 2>/dev/null || true
rm -rf .agents/skills/ambitions-*
rm -rf .codex/hooks .codex/rules .codex/schemas
rm -f .codex/hooks.json
rm -rf docs/codex-os
rm -f scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py scripts/ambitions-codex-os-print-install-notes.py
```

After cleanup, re-run:

```bash
git status --short
git diff --stat
```

If rollback is partial, keep diffs bounded and avoid broad resets.
