# Ambitions Codex Project Config

This repo uses project-scoped Codex config in `.codex/config.toml`.

## Trust And Loading

- Personal defaults live in `~/.codex/config.toml`.
- Repo overrides live in `.codex/config.toml`.
- Project config and repo-local skills are applied only when Codex trusts this repo.

## Profile Intent

- `small-edit`: single-file maintenance, copy cleanup, narrow docs truth fixes.
- `feature-build`: normal multi-file feature or wiring work inside the existing native architecture.
- `domain-safe`: planner, routing, persistence, or other higher-risk edits that should plan first.
- `release-check`: hardening, validation, and final docs/config truth passes.

## Profile Selection Notes

- Profiles are mainly a CLI/App workflow convenience, not a guarantee that every Codex surface exposes explicit profile switching the same way.
- Command-line overrides can still supersede config defaults when the invoking surface supports them.
- Profiles tune defaults; the autonomous loop itself still comes from `AGENTS.md`, skills, and templates.
- When in doubt for Ambitions work:
  - choose `small-edit` for narrow maintenance
  - choose `feature-build` for standard implementation
  - choose `domain-safe` for planner, persistence, routing, or container work
  - choose `release-check` for validation-heavy preflight work

## Autonomous Loop Fit

- `small-edit`: best when the loop can stay short and avoid a formal plan.
- `feature-build`: best for normal bounded execution after the task has been classified and scoped.
- `domain-safe`: best when the loop must start with planning and may need narrower retries.
- `release-check`: best when the loop is dominated by validation, hardening, stop conditions, and final reporting.

## Subagents

- Subagents are not part of the default Ambitions loop.
- Use them only when a user explicitly asks for delegated parallel review work. This repo does not assume automatic subagent spawning.
