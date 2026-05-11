# Ambitions No-Cost Codex OS

## Implemented

- Added local Codex authority files (`AGENTS.md`, `scripts/AGENTS.md`, `docs/AGENTS.md`, `.agents/AGENTS.md`, `.codex/AGENTS.md`).
- Added repo-scoped `.agents` Skills for runner safety, source-truth auditing, no-cost checks, quality gates, and rollback hygiene.
- Added local command rules in `.codex/rules/ambitions-no-cost.rules`.
- Added hook scripts under `.codex/hooks`, registered them in `.codex/hooks.json`, and enabled local hook execution in `.codex/config.toml`.
- Added schema and docs for structured batch output (`.codex/schemas/`, `docs/codex-os/STRUCTURED_OUTPUT.md`).
- Added local validator and doctor scripts.
- Added Makefile targets for Codex OS validation and doctor execution.

## Why this is no-new-cost

- No new dependencies added.
- No package installation commands added.
- No API-key wiring added.
- No hosted CI or GitHub workflow changes.
- All new assets run with shell/Python standard library and local files only.

## Deliberately excluded

- GitHub Actions workflow additions.
- Hosted CI integrations.
- OpenAI SDK / API runtime wiring.
- Agents SDK.
- MCP server installs.
- gpt-oss model runtime.
- Whisper / tiktoken / openai-cookbook dependencies.
- ChatKit / Apps SDK.
- Figma / Canva / paid design integrations.
- App Store upload/signing automation.
- Package managers or dependency-install commands.
- External CI/CD.
- External paid SaaS connectors.

## Activation notes

- Use `python3 scripts/ambitions-codex-os-validate.py` and `python3 scripts/ambitions-codex-os-doctor.py` after edits.
- Optional: `codex execpolicy check --rules .codex/rules/ambitions-no-cost.rules <command tokens>` when available.
- `.codex/config.toml` already enables `[features].hooks = true`; `.codex/hooks.json` registers the repo-local hook scripts.

## Report interpretation

- `GREEN`: required files exist, checks pass, no hard forbidden pattern, hooks compile.
- `YELLOW`: non-fatal warnings remain (for example rule-format ambiguity or optional checks unavailable).
- `RED`: hard policy or scope/forbidden-pattern failures.

## Safe extension guidance

- Add future skills under `.agents/skills/<slug>/SKILL.md` with YAML front matter.
- Add hooks/rules in `.codex` only when local-only and bounded.
- Keep scope additive and reversible.

## Avoiding false claims

- Do not claim release readiness, accessibility completion, or API-proof without evidence files.
- Keep all claims tied to local logs and validated commands.
