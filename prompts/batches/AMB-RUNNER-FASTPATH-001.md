<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-RUNNER-FASTPATH-001 - Runner Fastpath

Linear issue: AMB-RUNNER-FASTPATH-001 if present.
Status target: Green or accepted Yellow only.
Branch policy: work directly on `main`; do not create a branch or PR.

## Mission

Optimize the Ambitions batch runner for faster, safer packet execution while
preserving the same quality gates. This is runner/process infrastructure work
only. Do not implement product UI changes.

## Authority

- Use `docs/truth/PRODUCT_DESIGN_TRUTH.md` as product/design authority.
- Preserve `docs/truth/CODEX_PROCESS_TRUTH.md` Red/Yellow/Green and proof
  discipline.
- Do not weaken product/design, accessibility, privacy, proof, Red/Yellow/Green,
  champion coverage, parallel guard, or concept-lock gates.

## Allowed Scope

- `scripts/ambitions-codex-train.sh`
- Runner helper scripts directly invoked by the runner
- Guard helper scripts only if needed for runner status parsing or fast preflight
- Xcode validation wrapper scripts needed for stale focused-test prevention
- Runner/process docs or templates if required
- This prompt

## Forbidden Scope

- No product UI/source changes.
- No surface source changes.
- No design token/material/primitive changes.
- No `project.yml`, `Package.swift`, or generated Xcode changes.
- No screenshot, visual baseline, privacy manifest, or entitlement changes.
- No concept-lock weakening.
- No build/test/accessibility/proof bypass.

## Required Runner Improvements

- First-class dependency-clearance ingestion from prompt sections such as
  `PREVIOUS_PACKET_CLEARANCE:` or `## Dependency Clearance`.
- Prompt preflight self-heal for prompt wording, missing inspection terms, and
  stale prompt triggers before source work starts.
- Direct-main defaults for Master Frontend Maturity packets and explicit
  direct-main packets.
- Non-blocking accepted-Yellow continuation without restarting Phase 01.
- Bounded patch no-diff watchdog with explicit stall artifacts.
- Hardened status parsing for markdown/case/bullet/code-formatted status lines.
- Stale focused-test bundle prevention and focused-test artifact isolation.
- Locked-path precheck before bounded patching.
- Guard report clarity from existing guard JSON fields.
- Sparse progress output and compressed final report fields.
- `RUNNER_FASTPATH_SELFTEST=1` dry-run validation mode.

## Validation

- `git diff --check`
- `bash -n scripts/ambitions-codex-train.sh`
- `bash -n` on touched shell helpers
- `scripts/ambitions-codex-train.sh --self-check`
- `RUNNER_FASTPATH_SELFTEST=1 scripts/ambitions-codex-train.sh --self-check`
- `scripts/ambitions-prompt-audit.sh`

Run champion coverage and parallel guard pre/post only if guard metadata or
source-changing guard policy changes. Do not run broad Xcode builds unless
wrapper changes require more than shell-level validation.

## Linear Updates

Read existing Linear issues first. Update only existing issues found by key.
Comment on `AMB-514`, `AMB-516`, and `AMB-517` with runner behavior changes.
Do not change their status unless their own acceptance gates are completed by
their own issue work.

## Final Report

Use the Green / Yellow / Red closeout shape and include status, commit SHA if
pushed, runner behavior changes, defaults changed, gates preserved, validation,
proof artifacts, proof boundaries, rollback, Linear updates, and next command.

Expected next eligible command after Green or accepted Yellow:

```bash
Run Linear AMB-517
```
