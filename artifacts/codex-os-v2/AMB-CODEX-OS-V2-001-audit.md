# AMB-CODEX-OS-V2-001 Audit

Status: Yellow/Red existing drift documented
Date: 2026-06-11
Branch: main
Base HEAD before install: b5bfa2ed891a412e0d9e43b99c744422fe2a990c

## Current Codex OS Files Found

Active front doors: `AGENTS.md`, `.codex/OPERATING_SYSTEM.md`, `.codex/REPO_INVENTORY.md`, `.agents/AGENTS.md`. Active truth authority: `docs/truth/*`. Existing validators: `scripts/ambitions-codex-os-validate.py`, `scripts/ambitions-codex-os-doctor.py`. Existing Make targets include `ambitions-codex-os-validate`, `ambitions-codex-os-doctor`, `scripts-doctor`, `repo-doctor`, and `codex-os-*`. Existing supporting scripts include `scripts/codex-os/*`, `scripts/governance/*`, runner scripts, and proof/claim/safety scans. Existing skills are `.agents/skills/ambitions-*`; `.codex/skills/ambitions` was not found.

## Source Atlas / Linear Evidence

Source Atlas source/tooling exists under `Native/Ambitions/Domain/SourceAtlas*`, `Native/Ambitions/Runtime/SourceAtlas*`, `Native/AmbitionsTests/**/*SourceAtlas*`, `tools/source-atlas`, `tools/mcp/ambitions_source_atlas_mcp`, and Source Atlas scan scripts. Linear sync exists under `.linear-sync/ambitions-linear-sync.yml`, `.linear-sync/linear_sync_apply.py`, and `.linear-sync/reports/*`; repo truth wins and Linear requires local token/config for writes.

## Validator / Doctor Expectations

`ambitions-codex-os-validate.py` expects legacy no-cost/hardening assets, `.codex/skills/ambitions/*`, generated OS-FLAGSHIP prompts with runner headers, hook compilation, schema validation, and Codex execpolicy checks. `ambitions-codex-os-doctor.py` checks the same broad control-plane shape. `make scripts-doctor` checks script inventory and wrapper policy. `make repo-doctor` runs broad governance doctor scans.

## Missing / Stale / Extra Files

Missing before install: `.codex/AGENTS.md`, `.codex/rules/ambitions-no-cost.rules`, `.codex/schemas/ambitions-batch-result.schema.json`, legacy `docs/codex-os/*` hardening docs, `docs/codex/os/*`, `.codex/skills/ambitions/*`, and generated `OS-FLAGSHIP-*` prompts.

Stale conflict: active front doors require the old runner for Codex OS work by default, while v2 requires Goal Mode default for new program work.

Extra/noise risk: `.linear-sync/reports/latest-dry-run.md` contains historical runner commands for IOS26 prompts; those are supporting reports, not active Goal Mode authority.

## Current Runner Policy

Before this install, `AGENTS.md` and `CODEX_PROCESS_TRUTH.md` present the runner as active default for Codex OS and implementation work. This must be patched for v2.

## Runner Deprecation / Goal Mode Recommendation

Make Goal Mode the default for new autonomous work. Preserve the runner as legacy/supporting/historical and as an explicit active-issue path. Do not require runner headers or route new Goal Mode program work through `scripts/ambitions-codex-train.sh`.

## `/goal` Compatibility Risks

Future `/goal` runs can misroute through legacy runner prompts if active docs still require runner headers. GOAL files and run-state files must be first-class sources. Deterministic scripts must not call network, install packages, push git, or update Linear directly.

## No Parallel OS Conclusion

The safe install extends the existing OS: keep `AGENTS.md`, `docs/truth/*`, `.codex/OPERATING_SYSTEM.md`, `.codex/REPO_INVENTORY.md`, `.agents/`, `.linear-sync/`, Make targets, validators, and proof/no-claim policy. Add v2 standards and adapters without replacing truth files or deleting runner history.

## Safe Delta Install Scope

Allowed: requested `docs/codex-os`, `artifacts`, `.agents/skills`, `scripts/codex`, and active process-doc patches. Forbidden: `Native/`, `Sources/`, `AppUI/`, Xcode projects, `project.yml`, `Package.swift`, entitlements, resources, runtime behavior, dependencies, generated Xcode projects.

## Validation Commands Run

- `python3 scripts/ambitions-codex-os-validate.py` -> exit 1, log `artifacts/codex-os-v2/script-output/001-initial-ambitions-codex-os-validate.log`.
- `python3 scripts/ambitions-codex-os-doctor.py` -> exit 0, log `artifacts/codex-os-v2/script-output/001-initial-ambitions-codex-os-doctor.log`.
- `make scripts-doctor` -> exit 2, log `artifacts/codex-os-v2/script-output/001-initial-make-scripts-doctor.log`.
- `make repo-doctor` -> terminated after exceeding bounded interactive audit wait budget, log `artifacts/codex-os-v2/script-output/001-initial-make-repo-doctor.log`.

## Red / Yellow / Green

Green: audit completed with current evidence and no app source edits. Yellow: existing validator/doctor drift is outside this installer. Red: existing `ambitions-codex-os-validate.py` reports Red before install; this install does not claim that legacy validator is fixed.
