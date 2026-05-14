<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION

# Objective

Make Codex OS understandable from one visible human portal while preserving the active machine authority spine.

This phase must remove confusion between `.codex/`, `docs/codex/`, `docs/codex-os/`, `prompts/`, `scripts/`, `build/reports/`, generated run artifacts, and historical Codex material.

# Runner command

```bash
make batch BATCH=AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION PROMPT=prompts/batches/AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION.md
```

# Active source truth to inspect

```text
docs/status/repo-authority-cleanup-baseline.md
docs/status/repo-authority-cleanup-front-door-report.md
codex-os/README.md
.codex/OPERATING_SYSTEM.md
.codex/REPO_INVENTORY.md
.codex/SKILL_GOVERNANCE.md
docs/codex/CODEX_OS_INDEX.md
docs/codex-os/
docs/codex/
prompts/batches/
scripts/
build/reports/
docs/status/
```

# Allowed scope

```text
codex-os/README.md
.codex/REPO_INVENTORY.md
docs/codex/CODEX_OS_INDEX.md
docs/codex-os/**
docs/README.md
README.md
validation/README.md
history/README.md
docs/status/repo-authority-cleanup-codex-os-report.md
```

Move/archive only clearly historical Codex OS documentation if inbound links are updated and the historical/archive policy permits it. Otherwise classify and defer to Phase 5.

# Forbidden scope

- Do not rewrite `scripts/ambitions-codex-train.sh`.
- Do not remove `.codex/OPERATING_SYSTEM.md` or active governance.
- Do not delete proof artifacts required for traceability.
- Do not make `.codex/runs/` part of active repo content.
- Do not move active batch prompts into history.
- Do not claim cleanup execution is complete.

# Required target behavior

`codex-os/README.md` must be the human Codex OS portal and route to:

- Active machine control plane → `.codex/OPERATING_SYSTEM.md`
- Repo inventory → `.codex/REPO_INVENTORY.md`
- Supporting Codex docs → `docs/codex/`
- Batch prompts → `prompts/batches/`
- Validation scripts → `scripts/`
- Proof/status reports → `docs/status/`
- Historical Codex material → `history/` or the repo-approved archive location

`.codex/OPERATING_SYSTEM.md` remains the active machine authority.

# Required actions

1. Confirm Phases 0–3 are GREEN or stop RED.
2. Inspect Codex OS-related docs and classify them as active machine authority, active human portal, supporting docs, active prompts, generated proof/report, temporary artifact, historical, archive candidate, or unknown.
3. Update `codex-os/README.md` as the single visible human portal.
4. Update `.codex/REPO_INVENTORY.md` to reflect root portals and the new active/historical boundary.
5. Ensure `docs/codex/CODEX_OS_INDEX.md` is supporting, not a competing front door.
6. Classify `docs/codex-os/*`; move only clearly historical material if safe, otherwise defer with explicit classification.
7. Ensure generated run artifacts and `.codex/runs/` are not active repo content.
8. Write `docs/status/repo-authority-cleanup-codex-os-report.md` with classification, changes, validation, rollback, and deferred decisions.

# Validation expectations

Run and record:

```bash
git status --short
test -f codex-os/README.md
test -f .codex/OPERATING_SYSTEM.md
test -f .codex/REPO_INVENTORY.md
test -f docs/status/repo-authority-cleanup-codex-os-report.md
grep -n ".codex/OPERATING_SYSTEM.md" codex-os/README.md
grep -n "prompts/batches" codex-os/README.md
grep -n "scripts/" codex-os/README.md
grep -n "docs/status" codex-os/README.md
```

If link-check tooling exists, run it against touched Markdown. If no tool exists, manually verify touched links.

# Visual proof expectations

None. This phase must not change UI.

# Hard Red stop conditions

- Any prior phase is not GREEN.
- `.codex/OPERATING_SYSTEM.md` is weakened, moved, or contradicted.
- Multiple visible Codex OS front doors still claim primary authority.
- Historical Codex material remains presented as active.
- `.codex/runs/` becomes active content.
- Link validation fails.
- Runner script is modified.

# Rollback expectations

If committed, rollback is:

```bash
git revert <commit>
```

If uncommitted, list exact restore/move-back commands for touched files.

# GREEN criteria

- `codex-os/README.md` is the visible human portal.
- `.codex/OPERATING_SYSTEM.md` remains active machine authority.
- Supporting/historical Codex material is classified.
- Repo inventory reflects the new portal IA.
- Validation and rollback are documented.
