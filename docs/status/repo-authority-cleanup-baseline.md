# Repo Authority Cleanup Baseline

Status: Baseline snapshot for `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL`

## Evidence captured

- `git status --short --branch` reported `## main...origin/main`
- The worktree was clean before the Phase 02 patch began
- Starting commit from the batch handoff: `1bd307f468c4c0010c3b3f4c61f73cd4b893bca7`
- Current branch: `main`

## Baseline classification

- Active source truth spine exists in `docs/truth/`
- `docs/canon/frontend/` is the active visual-canon family being rehomed into `frontend/visual-encyclopedia/`
- `.env.example` contains stale hosted-backend placeholders
- `skills-lock.json` contains stale provider skill residue
- `docs/canon/README.md` still needs demotion from active-sounding canon to legacy/supporting routing
- Root portal files for `frontend`, `backend`, `codex-os`, `product-canon`, `validation`, and `history` were missing at baseline

## Baseline move candidates

- `docs/canon/frontend/**` -> `frontend/visual-encyclopedia/**`
- root portal READMEs
- `.env.example`
- `skills-lock.json`
- `.codex/REPO_INVENTORY.md`
- `.codex/SKILL_GOVERNANCE.md`
- `docs/codex/CODEX_OS_INDEX.md`
- `scripts/ambitions-repo-authority-validate.py`
