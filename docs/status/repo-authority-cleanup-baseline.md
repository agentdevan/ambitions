# Repo Authority Cleanup Baseline

Status: Baseline snapshot for `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL`

## Evidence captured

- `git status --short --branch` reported `## main...origin/main`
- `git rev-parse HEAD` reported `2937bcbbb4f344f58a12274ffb0890fd0f9c2b4c`
- The worktree was clean before the Phase 02 patch began
- Current branch: `main`

## Baseline classification

- Active source truth spine exists in `docs/truth/`
- The active visual-canon family already lives under `frontend/visual-encyclopedia/`
- `.env.example` is clean of hosted-backend placeholders in the current checkout
- `skills-lock.json` is clean of provider skill residue in the current checkout
- `docs/canon/README.md` already functions as a legacy/supporting canon index
- Root portal files for `frontend`, `backend`, `codex-os`, `product-canon`, `validation`, and `history` already exist in the current checkout
- One verified user-facing source drift item remains in scope for the phase: `Native/AmbitionsWidgetExtension/NextStepWidget.swift` still says `Open Focus`

## Baseline move candidates

- `README.md`
- `docs/status/repo-authority-cleanup-final-report.md`
- `docs/status/repo-authority-cleanup-active-path-allowlist.md`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
