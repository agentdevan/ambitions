<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

`AUTO-HARDEN-01`

# Objective

Harden the Ambitions hybrid runner and prompt-governance layer so a later
autonomous global batch train can run through the canonical runner without
unsafe defaults, broad staging, stale IA assumptions, or prompt-classification
ambiguity.

This is a Codex OS / runner governance batch. Do not implement app features.
Do not modify app UI. Do not run the full global train.

Required outcomes:

- default `AUTO_PUSH=0`
- no `git add -A`, no `git add .`, no `git commit -a`
- path-limited staging only
- active user-facing IA is `Today / Goals / Capture / Time / You`
- `Plan` is not promoted as active top-level IA
- branch policy conflicts are explicitly handled
- prompt audit classifies active runnable prompts versus templates, evals,
  historical prompts, and supporting governance docs
- runner self-check/dry-run exists and does not invoke real Codex phases
- docs match corrected defaults
- no app source changes
- no release, build, accessibility, performance, visual, device, TestFlight, or
  App Store readiness claims

# Active Source Truth To Inspect

Read first:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. `docs/truth/CODEX_PROCESS_TRUTH.md`
6. `docs/truth/HISTORICAL_POLICY.md`
7. `AGENTS.md`
8. `.codex/state/active-batch.yml`
9. `scripts/ambitions-codex-train.sh`
10. `scripts/ambitions-wrap-prompt.sh`
11. `scripts/ambitions-prompt-audit.sh`
12. `scripts/ambitions-runner-self-check.sh`
13. `Makefile`
14. `prompts/_RUNNER_REQUIRED_HEADER.md`
15. `prompts/_BATCH_TEMPLATE.md`
16. `docs/codex/ambitions-hybrid-runner.md`

# Allowed Scope

You may modify only:

- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-wrap-prompt.sh`
- `scripts/ambitions-prompt-audit.sh`
- `scripts/ambitions-runner-self-check.sh`
- `Makefile`
- `prompts/_RUNNER_REQUIRED_HEADER.md`
- `prompts/_BATCH_TEMPLATE.md`
- `docs/codex/ambitions-hybrid-runner.md`
- `docs/audits/auto-harden-01-report.md`

# Forbidden Scope

Do not modify:

- `Native/`
- `Sources/`
- `AppUI/`
- `Package.swift`
- `project.yml`
- `docs/truth/`
- `docs/status/release-evidence-packet.md`
- `docs/status/current-implementation-map.md`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`

Do not add dependencies, hosted CI, signing automation, App Store automation,
external/cloud LLM behavior, custom backend/provider behavior, network sync, or
release/readiness claims.

# Validation Expectations

Run and record exact command, exit code, and result:

```bash
git diff --check
bash -n scripts/ambitions-codex-train.sh
bash -n scripts/ambitions-wrap-prompt.sh
bash -n scripts/ambitions-prompt-audit.sh
bash -n scripts/ambitions-runner-self-check.sh
test -x scripts/ambitions-codex-train.sh
test -x scripts/ambitions-wrap-prompt.sh
test -x scripts/ambitions-prompt-audit.sh
test -x scripts/ambitions-runner-self-check.sh
make -n batch BATCH=TEST PROMPT=prompts/_BATCH_TEMPLATE.md
make -n prompt-audit
make -n batch-status
scripts/ambitions-codex-train.sh --self-check
scripts/ambitions-prompt-audit.sh
```

Do not run a real implementation batch.

# Hard Red Stop Conditions

Stop immediately with `STATUS: RED` if:

- app source would need to be touched
- `docs/truth/*` would need to be touched
- runner is missing
- broad staging or commit shortcuts are required
- self-check cannot avoid real Codex phase execution
- prompt audit cannot distinguish active runnable prompts from templates, evals,
  historical prompts, and supporting governance docs
- validation fails in a way that makes autonomous execution unsafe

# Final Report Format

End with:

```markdown
## Status

STATUS: GREEN | STATUS: YELLOW | STATUS: RED

## Scope

## Files Changed

## Runner Defaults

## Prompt Audit

## Self-Check

## Validation

## Claims Not Made

## Next Recommended Step
```

