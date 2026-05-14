# Repo Authority Cleanup Final Report

Status: Phase 03 review repair report for `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL`

## Scope

This cleanup is limited to repo authority, portal routing, frontend Visual Encyclopedia rehome, backend-posture honesty, Codex OS routing, and deterministic docs/control-plane validation.

No app source, truth files, active batch state, project configuration, package manifest, signing, hosted backend, hosted CI, or runtime dependency changes are part of this report.

## Result

- Root repo routing now starts at `README.md` and points to the root portals.
- The active frontend portal is `frontend/README.md`.
- The Visual Encyclopedia family lives under `frontend/visual-encyclopedia/`.
- Installed frontend canon is separated from intended frontend canon.
- Backend posture explicitly states that no hosted personal-data backend is claimed.
- Codex OS has a human portal at `codex-os/README.md`; `.codex/OPERATING_SYSTEM.md` remains machine authority.
- `docs/canon/README.md` is demoted to a legacy/supporting canon index.
- `.env.example` and `skills-lock.json` no longer advertise stale hosted-provider setup.
- `scripts/ambitions-repo-authority-validate.py` guards the portal set and active-language scan.

## Validation

Run from repo root:

```bash
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-authority-supersession-check.py
python3 scripts/ambitions-codex-os-validate.py
python3 scripts/ambitions-repo-authority-validate.py
git diff --check
```

Validation results are recorded by the reviewing phase summary. These commands prove docs/control-plane cleanup only; they do not prove build, test, accessibility, privacy/legal, performance, device, TestFlight, App Store, or production readiness.

## Rollback

Rollback this cleanup with path-limited restore:

```bash
git restore --staged -- README.md docs/README.md docs/AGENTS.md docs/canon/README.md .env.example skills-lock.json .codex/REPO_INVENTORY.md .codex/SKILL_GOVERNANCE.md docs/codex/CODEX_OS_INDEX.md scripts/ambitions-repo-authority-validate.py docs/status/repo-authority-cleanup-baseline.md docs/status/repo-authority-cleanup-active-path-allowlist.md docs/status/repo-authority-cleanup-final-report.md frontend backend codex-os product-canon validation history
git restore -- README.md docs/README.md docs/AGENTS.md docs/canon/README.md .env.example skills-lock.json .codex/REPO_INVENTORY.md .codex/SKILL_GOVERNANCE.md docs/codex/CODEX_OS_INDEX.md scripts/ambitions-repo-authority-validate.py docs/status/repo-authority-cleanup-baseline.md docs/status/repo-authority-cleanup-active-path-allowlist.md docs/status/repo-authority-cleanup-final-report.md frontend backend codex-os product-canon validation history
```

If git needs to undo the Visual Encyclopedia rehome after staging, inspect `git status --short` first and use path-limited restores only.
